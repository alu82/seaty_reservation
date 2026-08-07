defmodule SeatyReservation.ReservationsCapacityTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Reservations
  import SeatyReservation.ReservationsFixtures
  import SeatyReservation.EventsFixtures

  describe "reservation count functions" do
    test "get_reservation_count/1 sums seats for event" do
      event = event_fixture()

      reservation_fixture(%{"event_id" => event.id, "seats" => "3"})
      reservation_fixture(%{"event_id" => event.id, "seats" => "5"})
      reservation_fixture(%{"event_id" => event.id, "seats" => "2"})

      count = Reservations.get_reservation_count(event.id)
      assert count == 10
    end

    test "get_reservation_count/1 returns 0 for event with no reservations" do
      event = event_fixture()

      count = Reservations.get_reservation_count(event.id)
      assert count == 0
    end

    test "get_reservation_count/1 handles multiple events" do
      event1 = event_fixture()
      event2 = event_fixture()

      reservation_fixture(%{"event_id" => event1.id, "seats" => "3"})
      reservation_fixture(%{"event_id" => event1.id, "seats" => "2"})
      reservation_fixture(%{"event_id" => event2.id, "seats" => "5"})

      count1 = Reservations.get_reservation_count(event1.id)
      count2 = Reservations.get_reservation_count(event2.id)

      assert count1 == 5
      assert count2 == 5
    end

    test "get_reservation_count/0 groups by event_id" do
      event1 = event_fixture()
      event2 = event_fixture()

      reservation_fixture(%{"event_id" => event1.id, "seats" => "3"})
      reservation_fixture(%{"event_id" => event1.id, "seats" => "2"})
      reservation_fixture(%{"event_id" => event2.id, "seats" => "5"})

      counts = Reservations.get_reservation_count()

      assert length(counts) == 2
      assert {event1.id, 5} in counts
      assert {event2.id, 5} in counts
    end

    test "get_reservation_count/0 returns empty list when no reservations" do
      counts = Reservations.get_reservation_count()
      assert counts == []
    end

    test "get_reservation_count/0 returns all events with reservations" do
      event1 = event_fixture()
      event3 = event_fixture()

      reservation_fixture(%{"event_id" => event1.id, "seats" => "1"})
      reservation_fixture(%{"event_id" => event3.id, "seats" => "2"})
      # event2 has no reservations (not created)

      counts = Reservations.get_reservation_count()

      assert length(counts) == 2
      assert {event1.id, 1} in counts
      assert {event3.id, 2} in counts
    end
  end

  describe "capacity scenarios" do
    test "multiple reservations fill up event" do
      event = event_fixture(%{total_seats: 10})

      reservation_fixture(%{"event_id" => event.id, "seats" => "3"})
      reservation_fixture(%{"event_id" => event.id, "seats" => "4"})
      reservation_fixture(%{"event_id" => event.id, "seats" => "3"})

      total = Reservations.get_reservation_count(event.id)
      assert total == 10
    end

    test "reservation count matches sum of seats" do
      event = event_fixture(%{total_seats: 50})

      reservation_fixture(%{"event_id" => event.id, "seats" => "10"})
      reservation_fixture(%{"event_id" => event.id, "seats" => "15"})
      reservation_fixture(%{"event_id" => event.id, "seats" => "25"})

      total = Reservations.get_reservation_count(event.id)
      assert total == 50
    end

    test "cancelled reservations (seats=0) don't contribute to count" do
      event = event_fixture(%{total_seats: 10})

      reservation_fixture(%{"event_id" => event.id, "seats" => "5"})
      reservation_fixture(%{"event_id" => event.id, "seats" => "0", "prio" => "0"})
      reservation_fixture(%{"event_id" => event.id, "seats" => "3"})

      total = Reservations.get_reservation_count(event.id)
      # Only 5 + 3 = 8, the cancelled one with 0 seats doesn't add
      assert total == 8
    end
  end
end
