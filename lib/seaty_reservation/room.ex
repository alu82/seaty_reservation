defmodule SeatyReservation.Room do
  @moduledoc """
  Single source of truth for the physical theatre room layout.

  The room is keyed by 1-indexed row number. Each row carries:
  - `seats`    - number of physical seats in that row
  - `category` - pricing/category tier (used e.g. by allocation distance logic)
  - `section`  - visual grouping for rendering (grid block)

  All layout numbers live here. Consumers derive what they need; none
  hardcode row counts or seat counts.
  """

  # 1-indexed by row number (rows 1..13)
  @rows %{
    1 => %{seats: 24, category: 2, section: 1},
    2 => %{seats: 24, category: 1, section: 1},
    3 => %{seats: 24, category: 1, section: 1},
    4 => %{seats: 24, category: 2, section: 1},
    5 => %{seats: 19, category: 4, section: 2},
    6 => %{seats: 19, category: 3, section: 2},
    7 => %{seats: 19, category: 3, section: 2},
    8 => %{seats: 19, category: 3, section: 2},
    9 => %{seats: 19, category: 4, section: 2},
    10 => %{seats: 4, category: 5, section: 3},
    11 => %{seats: 4, category: 5, section: 3},
    12 => %{seats: 4, category: 5, section: 3},
    13 => %{seats: 4, category: 5, section: 3}
  }

  @doc "Full row map, 1-indexed by row number."
  def rows, do: @rows

  @doc "Number of seats in a row (1-indexed)."
  def seats(row) when is_integer(row), do: @rows[row].seats

  @doc "Category of a row (1-indexed)."
  def category(row) when is_integer(row), do: @rows[row].category

  @doc "Section of a row (1-indexed)."
  def section(row) when is_integer(row), do: @rows[row].section

  @doc "Total number of rows."
  def total_rows, do: map_size(@rows)

  @doc "Sorted row numbers (1-indexed)."
  def row_numbers, do: @rows |> Map.keys() |> Enum.sort()

  @doc """
  Sections in order, each as `{section, [{row, seats}, ...]}` with rows sorted.
  Used to render one grid block per section.
  """
  def sections do
    @rows
    |> Enum.group_by(fn {_, v} -> v.section end, fn {r, v} -> {r, v.seats} end)
    |> Enum.sort_by(fn {section, _} -> section end)
    |> Enum.map(fn {section, rows} -> {section, Enum.sort_by(rows, &elem(&1, 0))} end)
  end

  @doc """
  Flat list of seat counts per row, 0-indexed order (row 1 first).
  Used to build the 0-indexed allocation location list.
  """
  def seat_counts, do: Enum.map(row_numbers(), fn r -> @rows[r].seats end)

  @doc """
  Last 0-indexed row number belonging to the first section.
  `validate_options` uses this to keep "first block" semantics without a
  hardcoded row count.
  """
  def first_section_last_index do
    {_, first_rows} = hd(sections())
    length(first_rows) - 1
  end
end
