defmodule SeatyReservation.EventsWithProductionTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Events
  alias SeatyReservation.Productions
  alias SeatyReservation.Events.Event
  alias SeatyReservation.Productions.Production

  import SeatyReservation.EventsFixtures
  import SeatyReservation.ProductionsFixtures

  describe "events with production association" do
    test "create_event/1 with production_id creates event with production" do
      production = production_fixture()

      valid_attrs = %{
        active: true,
        datetime: ~N[2023-09-10 21:17:00],
        total_seats: 42,
        production_id: production.id,
        code: "TEST"
      }

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
      assert event.production_id == production.id
    end

    test "create_event/1 without production_id returns error" do
      valid_attrs = %{
        active: true,
        datetime: ~N[2023-09-10 21:17:00],
        total_seats: 42,
        code: "TEST"
      }

      assert {:error, %Ecto.Changeset{}} = Events.create_event(valid_attrs)
    end

    test "get_event!/1 includes production association" do
      production = production_fixture()
      event = event_fixture(%{production_id: production.id})

      fetched_event = Events.get_event!(event.id)
      assert fetched_event.production_id == production.id
    end

    test "delete_production/1 cascades to delete events" do
      production = production_fixture()
      event = event_fixture(%{production_id: production.id})

      assert {:ok, %Production{}} = Productions.delete_production(production)

      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end
  end
end
