defmodule SeatyReservation.AllocationsDistanceBugTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Allocations

  @tag :distance_range_bug
  test "reservation with 2 seats should wait for better spot via retry" do
    # Create an event
    event = SeatyReservation.EventsFixtures.event_fixture(%{total_seats: 100})

    _reservation1 = SeatyReservation.ReservationsFixtures.reservation_fixture(%{
      "event_id" => event.id,
      "seats" => 5,
      "prio" => 100,
      "group" => nil
    })

    _reservation2 = SeatyReservation.ReservationsFixtures.reservation_fixture(%{
      "event_id" => event.id,
      "seats" => 5,
      "prio" => 99,
      "group" => nil
    })

    _reservation3 = SeatyReservation.ReservationsFixtures.reservation_fixture(%{
      "event_id" => event.id,
      "seats" => 14,
      "prio" => 98,
      "group" => nil
    })

    _reservation4 = SeatyReservation.ReservationsFixtures.reservation_fixture(%{
      "event_id" => event.id,
      "seats" => 14,
      "prio" => 97,
      "group" => nil
    })

    reservation5 = SeatyReservation.ReservationsFixtures.reservation_fixture(%{
      "event_id" => event.id,
      "seats" => 2,
      "prio" => 96,
      "group" => nil
    })

    _reservation6 = SeatyReservation.ReservationsFixtures.reservation_fixture(%{
      "event_id" => event.id,
      "seats" => 1,
      "prio" => 95,
      "group" => nil
    })

    # Run allocation
    result = Allocations.allocate_event(event.id)

    # Find R5's assignment
    r5 = Enum.find(result.assigned, &(&1.code == reservation5.code))

    assert r5 != nil, "R005 should be allocated"

    assert r5.row in [2, 3],
      "R005 should be in row 2 or 3 (1-indexed), but was in row #{r5.row}. " <>
      "This indicates the bug: R5 was placed suboptimally instead of waiting for a better spot via retry."
  end
end
