defmodule SeatyReservation.ReservationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SeatyReservation.Reservations` context.
  """

  @doc """
  Generate a reservation.
  """
  def reservation_fixture(attrs \\ %{}) do
    {:ok, reservation} =
      attrs
      |> Enum.into(%{
        code: "some code",
        name: "some name",
        group: 42,
        comment: "some comment",
        prio: 42,
        order_date: ~N[2023-09-10 21:16:00],
        contact: "some contact",
        preferred_row: "some preferred_row"
      })
      |> SeatyReservation.Reservations.create_reservation()

    reservation
  end
end
