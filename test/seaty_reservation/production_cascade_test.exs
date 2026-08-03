defmodule SeatyReservation.ProductionCascadeTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Productions
  alias SeatyReservation.Events
  alias SeatyReservation.Reservations

  import SeatyReservation.ProductionsFixtures
  import SeatyReservation.EventsFixtures
  import SeatyReservation.ReservationsFixtures

  describe "cascading deletion" do
    test "deleting a production deletes all its events and reservations" do
      production = production_fixture()
      event1 = event_fixture(%{production_id: production.id})
      event2 = event_fixture(%{production_id: production.id})
      reservation1 = reservation_fixture(%{"event_id" => to_string(event1.id)})
      reservation2 = reservation_fixture(%{"event_id" => to_string(event2.id)})

      assert {:ok, _} = Productions.delete_production(production)

      assert_raise Ecto.NoResultsError, fn -> Productions.get_production!(production.id) end
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event1.id) end
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event2.id) end
      assert_raise Ecto.NoResultsError, fn -> Reservations.get_reservation!(reservation1.id) end
      assert_raise Ecto.NoResultsError, fn -> Reservations.get_reservation!(reservation2.id) end
    end
  end
end
