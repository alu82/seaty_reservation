defmodule SeatyReservation.AllocationsValidationTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Allocations

  describe "validation rule precedence" do
    test "all seats in row overrides diagonal positioning - full allocation scenario" do
      # Create an event with total_seats = 207 (4x24 + 5x19 + 4x4)
      event = SeatyReservation.EventsFixtures.event_fixture(%{total_seats: 207})

      # Fill rows 1-4 completely: 4 reservations of 24 seats each
      for row <- 1..4 do
        SeatyReservation.ReservationsFixtures.reservation_fixture(%{
          "event_id" => event.id,
          "seats" => 24,
          "group" => row,
          "prio" => 200 - row
        })
      end

      # Fill rows 5-9 with 15 seats each, leaving 4 seats free per row
      # 5 rows x 19 seats = 95 seats total
      # 5 reservations x 15 seats = 75 seats occupied
      # 20 seats remaining (4 per row x 5 rows)
      for row <- 5..9 do
        SeatyReservation.ReservationsFixtures.reservation_fixture(%{
          "event_id" => event.id,
          "seats" => 15,
          "group" => row,
          "prio" => 190 - row
        })
      end

      # Create a reservation for 4 seats that should fit in the remaining space
      # This should be able to take the 4 free seats in any of rows 5-9
      # Even though it starts at an odd seat index (15), taking all remaining seats
      # in the row should be valid (condition 3 overrides condition 2)
      reservation_4seats =
        SeatyReservation.ReservationsFixtures.reservation_fixture(%{
          "event_id" => event.id,
          "seats" => 4,
          "group" => 100,
          "prio" => 100
        })

      # Allocate
      result = Allocations.allocate_event(event.id)

      # Find the 4-seat reservation in results
      assigned_codes = Enum.map(result.assigned, & &1.code)

      assert length(result.unallocated) == 0

      # The 4-seat reservation should be assigned (not unallocated)
      assert reservation_4seats.code in assigned_codes,
        "4-seat reservation should be assigned when it takes all remaining seats in a row"

      # Find the assigned seat for TEST_4SEATS
      test_assignment = Enum.find(result.assigned, &(&1.code == reservation_4seats.code))

      # It should be assigned in one of rows 5-9
      assert test_assignment.row >= 5 && test_assignment.row <= 9,
        "4-seat reservation should be allocated in rows 5-9, got row #{test_assignment.row}"

    end
  end
end
