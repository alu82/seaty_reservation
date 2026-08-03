defmodule SeatyReservation.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SeatyReservation.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture do
    event_fixture(%{})
  end

  def event_fixture(attrs) do
    production = SeatyReservation.ProductionsFixtures.production_fixture()

    default_attrs = %{
      active: true,
      datetime: ~N[2023-09-10 21:17:00],
      total_seats: 42,
      production_id: production.id
    }

    merged_attrs = attrs |> Enum.into(default_attrs)
    {:ok, event} = SeatyReservation.Events.create_event(merged_attrs)
    event
  end
end
