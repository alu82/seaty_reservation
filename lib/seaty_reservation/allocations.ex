defmodule SeatyReservation.Allocations do
  @moduledoc """
  The Allocations context.

  Handles seat allocation for reservations in an event.
  Allocations are transient (not stored in database).
  """

  alias SeatyReservation.Reservations

  @distance_range 8

  @doc """
  Allocates seats for all reservations of a specific event.

  Returns a map with:
    - :assigned - list of %{row: integer, seat: integer, code: string, group: integer}
    - :unallocated - list of %{code: string, group: integer, seats: integer}
  """
  def allocate_event(event_id) do
    reservations = Reservations.get_reservations_by_event(event_id)
    allocate_event_from_reservations(reservations)
  end

  defp allocate_event_from_reservations(reservations) do
    # Filter out cancelled reservations (prio = 0) and reservations with 0 seats
    active_reservations =
      reservations
      |> Enum.filter(fn r -> r.prio != 0 && r.seats > 0 end)
      |> Enum.sort_by(fn r -> {-r.prio, r.code} end)

    # Build room location: 13 rows
    # 4 rows of 24 seats (index 0-3)
    # 5 rows of 19 seats (index 4-8)
    # 4 rows of 4 seats (index 9-12)
    location = build_location()

    # Group reservations: reservations with group == nil are each in their own group
    # Other reservations are grouped by their group value
    # Sort all reservations by priority first, then group them
    # This ensures groups are in priority order
    groups = group_reservations_by_priority(active_reservations)

    # Build a map from reservation code to group for later lookup
    code_to_group = Map.new(active_reservations, &{&1.code, &1.group})

    # Allocate groups with retry mechanism using recursion
    {assigned, not_allocated, _final_location} =
      allocate_groups_recursive(groups, code_to_group, active_reservations, location, 0, [])

    # Flatten assigned list and sort by row ascending, then seat ascending
    assigned_list = assigned |> List.flatten()
      |> Enum.sort_by(fn a -> {a.row, a.seat} end)

    %{assigned: assigned_list, unallocated: not_allocated}
  end

  @doc """
  Groups reservations by priority and group.
  Reservations with group == nil are each in their own group.
  Other reservations are grouped by their group value.
  Groups are ordered by priority (highest first).
  """
  def group_reservations_by_priority(reservations) do
    # Sort all reservations by priority (higher priority first)
    sorted = Enum.sort_by(reservations, fn r -> {-r.prio, r.code} end)

    # Group them, with nil groups being individual
    # Use a manual grouping to preserve priority order
    Enum.reduce(sorted, {[], nil, []}, fn res, {groups_acc, current_group, current_group_seats} ->
      if res.group == nil || res.group != current_group do
        # Start new group
        new_groups = if current_group_seats != [], do: groups_acc ++ [current_group_seats], else: groups_acc
        new_current_group_seats = [res]
        {new_groups, res.group, new_current_group_seats}
      else
        # Add to current group
        {groups_acc, current_group, current_group_seats ++ [res]}
      end
    end)
    |> then(fn {groups_acc, _current_group, current_group_seats} ->
      # Add the last accumulated group
      if current_group_seats != [], do: groups_acc ++ [current_group_seats], else: groups_acc
    end)
    |> Enum.map(fn res_list ->
      # Convert reservation list to seat list (duplicate codes by seat count)
      Enum.flat_map(res_list, &List.duplicate(&1.code, &1.seats))
    end)
  end

  defp allocate_groups_recursive(groups, code_to_group, reservations, location, idx, assigned_indices) do
    if idx >= length(groups) do
      # Build not_allocated list from groups that weren't assigned
      not_allocated =
        groups
        |> Enum.with_index()
        |> Enum.filter(fn {_group, i} -> !Enum.member?(assigned_indices, i) end)
        |> Enum.map(fn {group_seats, _i} ->
          first_code = hd(group_seats)
          %{code: first_code, group: code_to_group[first_code], seats: length(group_seats)}
        end)

      {[], not_allocated, location}
    else
      group_seats = Enum.at(groups, idx)

      if Enum.member?(assigned_indices, idx) do
        # Already assigned, move to next
        allocate_groups_recursive(groups, code_to_group, reservations, location, idx + 1, assigned_indices)
      else
        row_wishes = get_row_wishes(reservations, MapSet.new(group_seats))
        case allocate_group(location, group_seats, row_wishes) do
          {true, new_loc, placed_seats} ->
            # Extract allocation info from placed seats
            alloc_info =
              placed_seats
              |> Enum.map(fn {row, seat, code} ->
                %{row: row + 1, seat: seat + 1, code: code, group: code_to_group[code]}
              end)

            # Allocate and restart from beginning
            {a, na, l} = allocate_groups_recursive(
              groups,
              code_to_group,
              reservations,
              new_loc,
              0,  # Restart from beginning
              [idx | assigned_indices]
            )
            {[alloc_info | a], na, l}
          {false, _new_loc, _} ->
            # Cannot allocate this group yet, try next
            allocate_groups_recursive(groups, code_to_group, reservations, location, idx + 1, assigned_indices)
        end
      end
    end
  end

  def build_location do
    # 4 rows of 24 seats
    rows_1_4 = for _ <- 1..4, do: List.duplicate(nil, 24)
    # 5 rows of 19 seats
    rows_5_9 = for _ <- 1..5, do: List.duplicate(nil, 19)
    # 4 rows of 4 seats
    rows_10_13 = for _ <- 1..4, do: List.duplicate(nil, 4)
    rows_1_4 ++ rows_5_9 ++ rows_10_13
  end

  defp get_row_wishes(reservations, reservation_codes) do
    reservations
    |> Enum.filter(fn r -> Enum.member?(reservation_codes, r.code) && r.preferred_row && r.preferred_row != "" end)
    |> Enum.flat_map(fn r ->
      case Integer.parse(r.preferred_row) do
        {num, _} -> [num]
        :error -> []
      end
    end)
    |> Enum.uniq()
  end

  defp allocate_group(location, group_seats, row_wishes) do
    number_of_seats = length(group_seats)
    options = find_all_options(location, number_of_seats)
    valid_options = validate_options(location, options)
    filtered_options = find_options(valid_options, row_wishes)

    case filtered_options do
      [] -> {false, location, []}
      _ ->
        sorted_options = Enum.sort_by(filtered_options, &elem(&1, 3))
        best_option = hd(sorted_options)
        {row_nr, seat_nr, last_nr, _distance} = best_option

        # Place each seat in the group
        placed_seats =
          Enum.map(seat_nr..last_nr, fn seat_offset ->
            {row_nr, seat_offset, Enum.at(group_seats, seat_offset - seat_nr)}
          end)

        # Update location
        new_location =
          Enum.reduce(seat_nr..last_nr, location, fn seat_offset, loc ->
            new_row =
              loc
              |> Enum.at(row_nr)
              |> List.replace_at(seat_offset, Enum.at(group_seats, seat_offset - seat_nr))
            List.replace_at(loc, row_nr, new_row)
          end)

        {true, new_location, placed_seats}
    end
  end

  defp find_all_options(location, number_of_seats) do
    Enum.with_index(location)
    |> Enum.flat_map(fn {row, row_nr} ->
      # Find first valid option in this row and stop (matching Python break)
      case find_first_option_in_row(row, row_nr, number_of_seats) do
        nil -> []
        option -> [option]
      end
    end)
  end

  defp find_first_option_in_row(row, row_nr, number_of_seats) do
    Enum.reduce_while(Enum.with_index(row), nil, fn {_seat, seat_nr}, acc ->
      if acc != nil do
        {:halt, acc}
      else
        last_nr = seat_nr + number_of_seats - 1
        if last_nr < length(row) do
          window = Enum.slice(row, seat_nr..last_nr)
          if Enum.all?(window, &(&1 == nil)) do
            distance = get_distance(row_nr, last_nr)
            {:halt, {row_nr, seat_nr, last_nr, distance}}
          else
            {:cont, nil}
          end
        else
          {:cont, nil}
        end
      end
    end)
  end

  defp find_options(options, row_wishes) do
    case options do
      [] -> []
      _ ->
        if row_wishes != [] do
          # Filter by row wishes (note: row_wishes are 1-indexed, row_nr is 0-indexed)
          Enum.filter(options, fn {row_nr, _, _, _} -> Enum.member?(row_wishes, row_nr + 1) end)
        else
          min_distance = Enum.min_by(options, &elem(&1, 3)) |> elem(3)
          Enum.filter(options, fn {_, _, _, distance} -> distance <= min_distance + @distance_range end)
        end
    end
  end

  @doc """
  Validates allocation options based on various constraints.
  """
  def validate_options(location, options) do
    Enum.filter(options, fn option ->
      {row_nr, seat_nr, last_nr, _} = option
      row = Enum.at(location, row_nr)
      number_of_seats = last_nr - seat_nr + 1
      free_in_row = length(Enum.filter(row, &(&1 == nil)))

      cond do
        # We don't want to leave one single seat free in front rows
        row_nr < 4 and number_of_seats == free_in_row - 1 -> false
        # Not a diagonal positioning for pairs
        rem(number_of_seats, 2) == 0 && rem(seat_nr, 2) == 1 -> false
        # If all seats in row are free, it's valid
        number_of_seats == free_in_row -> true
        # Otherwise valid
        true -> true
      end
    end)
  end

  defp get_distance(row_nr, seat_nr) do
    distance = seat_nr

    # Row-based adjustments (matching Python notebook)
    # if row_nr not in [1,2]: distance += 12
    distance = if row_nr in [1, 2], do: distance, else: distance + 12
    # if row_nr > 3: distance += 30
    distance = if row_nr > 3, do: distance + 30, else: distance
    # if row_nr in [4,8,9,10,11,12]: distance += 2
    distance = if row_nr in [4, 8, 9, 10, 11, 12], do: distance + 2, else: distance
    # if row_nr > 8: distance += 30
    distance = if row_nr > 8, do: distance + 30, else: distance

    distance
  end

  @doc """
  Creates an allocation for the given reservations.
  """
  def create_allocation(reservations)
  def create_allocation(reservations) when is_list(reservations) do
    allocate_event_from_reservations(reservations)
  end

  def create_allocation(attrs \\ %{}) do
    # For backwards compatibility with any code that might call this
    Map.keys(attrs)
  end
end
