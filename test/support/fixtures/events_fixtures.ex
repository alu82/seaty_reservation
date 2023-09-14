defmodule SeatyReservation.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SeatyReservation.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        active: true,
        datetime: ~N[2023-09-10 21:17:00],
        total_seats: 42
      })
      |> SeatyReservation.Events.create_event()

    event
  end
end
