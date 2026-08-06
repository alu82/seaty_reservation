defmodule SeatyReservation.EventsCodeTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Events
  alias SeatyReservation.Events.Event

  describe "event code field" do
    test "event has code field" do
      production = SeatyReservation.ProductionsFixtures.production_fixture()

      attrs = %{
        active: true,
        datetime: ~N[2023-09-10 21:17:00],
        total_seats: 42,
        production_id: production.id,
        code: "TEST"
      }

      assert {:ok, %Event{code: "TEST"} = event} = Events.create_event(attrs)
      assert event.code == "TEST"
    end

    test "code field is required" do
      production = SeatyReservation.ProductionsFixtures.production_fixture()

      attrs = %{
        active: true,
        datetime: ~N[2023-09-10 21:17:00],
        total_seats: 42,
        production_id: production.id
      }

      assert {:error, %Ecto.Changeset{}} = Events.create_event(attrs)
    end
  end
end
