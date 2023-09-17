defmodule SeatyReservation.Reservations do
  @moduledoc """
  The Reservations context.
  """

  import Ecto.Query, warn: false
  alias SeatyReservation.Repo

  alias SeatyReservation.Reservations.Reservation

  @doc """
  Returns the list of reservations.

  ## Examples

      iex> list_reservations()
      [%Reservation{}, ...]

  """
  def list_reservations do
    Repo.all(Reservation)
  end

  @doc """
  Gets a single reservation.

  Raises `Ecto.NoResultsError` if the Reservation does not exist.

  ## Examples

      iex> get_reservation!(123)
      %Reservation{}

      iex> get_reservation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reservation!(id), do: Repo.get!(Reservation, id)

  @doc """
  Creates a reservation.

  ## Examples

      iex> create_reservation(%{field: value})
      {:ok, %Reservation{}}

      iex> create_reservation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reservation(attrs \\ %{}) do
    attrs = attrs
    |> Map.put("code", get_next_code(attrs["event_id"]))
    |> Map.put("prio", get_next_prio(attrs["event_id"]))
    |> Map.put("token", gen_access_token())

    %Reservation{}
    |> Reservation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a reservation.

  ## Examples

      iex> update_reservation(reservation, %{field: new_value})
      {:ok, %Reservation{}}

      iex> update_reservation(reservation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reservation(%Reservation{} = reservation, attrs) do
    reservation
    |> Reservation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a reservation.

  ## Examples

      iex> delete_reservation(reservation)
      {:ok, %Reservation{}}

      iex> delete_reservation(reservation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reservation(%Reservation{} = reservation) do
    Repo.delete(reservation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reservation changes.

  ## Examples

      iex> change_reservation(reservation)
      %Ecto.Changeset{data: %Reservation{}}

  """
  def change_reservation(%Reservation{} = reservation, attrs \\ %{}) do
    Reservation.changeset(reservation, attrs)
  end

  def get_reservation_by_code(code) do
    query =
      from r in Reservation,
      where: r.code == ^code
    Repo.one(query)
  end

  defp get_next_code(event_id) do
    query =
      from r in Reservation,
      where: r.event_id == ^event_id,
      select: count(r.id) |> coalesce(1)
    code = Repo.one(query) + String.to_integer(event_id)*1000
    check_next_codes(code, get_reservation_by_code(Integer.to_string(code)), code + 1)
  end

  defp check_next_codes(code, nil, _next_code) do
    code |> Integer.to_string()
  end

  defp check_next_codes(_code, count, next_code) when count > 0 do
    check_next_codes(next_code, get_reservation_by_code(Integer.to_string(next_code)), next_code + 1)
  end

  defp get_next_prio(event_id) do
    query =
      from r in Reservation,
      where: r.event_id == ^event_id,
      select: min(r.prio) |> coalesce(1000)
    Repo.one(query) - 5
  end

  defp gen_access_token() do
    :crypto.strong_rand_bytes(32)
    |> Base.encode64
    |> binary_part(0, 32)
  end

  def get_reservation_count(event_id) do
    query =
      from r in Reservation,
      where: r.event_id == ^event_id,
      select: sum(r.seats) |> coalesce(0)
    Repo.one(query)
  end

  def get_reservation_count() do
    query =
      from r in Reservation,
      select: {r.event_id, sum(r.seats) |> coalesce(0)},
      group_by: r.event_id
    Repo.all(query)
  end

end
