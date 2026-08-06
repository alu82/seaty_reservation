defmodule SeatyReservation.AllocationsTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Allocations

  describe "allocations" do
    test "allocate_event/1 returns assigned and unallocated reservations" do
      # Create an event with enough seats
      event = SeatyReservation.EventsFixtures.event_fixture(%{total_seats: 200})

      # Create reservations that can be allocated
      _reservation1 =
        SeatyReservation.ReservationsFixtures.reservation_fixture(%{
          "event_id" => event.id,
          "seats" => 2,
          "group" => 1,
          "code" => "R001",
          "prio" => 100
        })

      _reservation2 =
        SeatyReservation.ReservationsFixtures.reservation_fixture(%{
          "event_id" => event.id,
          "seats" => 3,
          "group" => 2,
          "code" => "R002",
          "prio" => 95
        })

      # Call allocation
      result = Allocations.allocate_event(event.id)

      # Should have assigned reservations
      assert Map.has_key?(result, :assigned)
      assert Map.has_key?(result, :unallocated)

      # All reservations should be assigned (2 + 3 = 5 seats, event has 200)
      # 2 seats for R001 + 3 seats for R002
      assert length(result.assigned) == 5
      assert length(result.unallocated) == 0
    end

    test "allocate_event/1 handles unallocated reservations" do
      event = SeatyReservation.EventsFixtures.event_fixture(%{total_seats: 207})

      # Create a reservation that needs more contiguous seats than any row has
      # Max row size is 24, so requesting 25 seats won't fit
      _reservation1 =
        SeatyReservation.ReservationsFixtures.reservation_fixture(%{
          "event_id" => event.id,
          "seats" => 25,
          "group" => 1,
          "code" => "R001",
          "prio" => 100
        })

      result = Allocations.allocate_event(event.id)

      # Reservation needing 25 contiguous seats should be unallocated
      assert length(result.unallocated) == 1
      assert hd(result.unallocated).seats == 25
    end

    test "allocate_event/1 handles multiple unallocated reservations in same group separately" do
      event = SeatyReservation.EventsFixtures.event_fixture(%{total_seats: 207})

      # Create two reservations in the same group that cannot be allocated
      # Max row size is 24, so requesting 25 seats won't fit
      reservation1 =
        SeatyReservation.ReservationsFixtures.reservation_fixture(%{
          "event_id" => event.id,
          "seats" => 25,
          "group" => 1,
          "prio" => 100
        })

      reservation2 =
        SeatyReservation.ReservationsFixtures.reservation_fixture(%{
          "event_id" => event.id,
          "seats" => 25,
          "group" => 1,
          "prio" => 100
        })

      result = Allocations.allocate_event(event.id)

      # Both reservations should be unallocated as separate entries
      assert length(result.unallocated) == 2

      # Check that both entries have the correct seat counts
      seats_list = Enum.map(result.unallocated, & &1.seats)
      assert Enum.sort(seats_list) == [25, 25]

      # Both should have group 1
      assert Enum.all?(result.unallocated, &(&1.group == 1))

      # Check that the codes match the original reservations
      codes = Enum.map(result.unallocated, & &1.code)
      assert reservation1.code in codes
      assert reservation2.code in codes
    end

    test "group_reservations_by_priority/1 groups reservations correctly by priority and group" do
      # Create test reservations as structs
      # Note: We need to create structs manually since fixtures go to DB
      # But for unit testing the grouping function, we can use maps

      # Reservation 1: 2 seats, prio 300, group nil
      res1 = %SeatyReservation.Reservations.Reservation{
        code: "R001",
        seats: 2,
        prio: 300,
        group: nil
      }

      # Reservation 2: 3 seats, prio 299, group 1
      res2 = %SeatyReservation.Reservations.Reservation{
        code: "R002",
        seats: 3,
        prio: 299,
        group: 1
      }

      # Reservation 3: 5 seats, prio 298, group 1
      res3 = %SeatyReservation.Reservations.Reservation{
        code: "R003",
        seats: 5,
        prio: 298,
        group: 1
      }

      # Reservation 4: 2 seats, prio 295, group nil
      res4 = %SeatyReservation.Reservations.Reservation{
        code: "R004",
        seats: 2,
        prio: 295,
        group: nil
      }

      # Call the grouping function
      groups = Allocations.group_reservations_by_priority([res1, res2, res3, res4])

      # Should have 3 groups
      assert length(groups) == 3

      # First group: R001 with 2 seats
      first_group = hd(groups)
      assert length(first_group) == 2
      assert Enum.all?(first_group, &(&1 == "R001"))

      # Second group: R002 (3 seats) + R003 (5 seats) = 8 seats, same group 1
      second_group = Enum.at(groups, 1)
      assert length(second_group) == 8
      assert Enum.count(second_group, &(&1 == "R002")) == 3
      assert Enum.count(second_group, &(&1 == "R003")) == 5

      # Verify priority order within group: R002 (prio 299) should come before R003 (prio 298)
      # Find the first occurrence of R002 and R003 in the second group
      r002_index = Enum.find_index(second_group, &(&1 == "R002"))
      r003_index = Enum.find_index(second_group, &(&1 == "R003"))
      assert r002_index < r003_index

      # Third group: R004 with 2 seats
      third_group = Enum.at(groups, 2)
      assert length(third_group) == 2
      assert Enum.all?(third_group, &(&1 == "R004"))
    end

    test "validate_options/2 rejects even-sized reservations starting on even seats (1-indexed)" do
      # Build a location with enough free seats
      location = SeatyReservation.Allocations.build_location()

      # Test case: 2 seats starting at seat 1 (0-indexed) which is seat 2 (1-indexed) - should be rejected
      # In 0-indexed: seat_nr=1 is odd, number_of_seats=2 is even
      # The validation should reject this because rem(2, 2) == 0 && rem(1, 2) == 1

      # Create an option that starts at row 0, seat 1 (0-indexed) = row 1, seat 2 (1-indexed)
      # This is 2 seats: seats 1 and 2 (0-indexed) = seats 2 and 3 (1-indexed)
      # Since 2 seats is even and starts at odd 0-indexed seat, it should be rejected
      options = [
        # row 0, seat 1 to 2 (0-indexed), distance 0
        {0, 1, 2, 0}
      ]

      valid_options = SeatyReservation.Allocations.validate_options(location, options)

      # This option should be filtered out
      assert length(valid_options) == 0

      # Test case: 2 seats starting at seat 0 (0-indexed) which is seat 1 (1-indexed) - should be valid
      # In 0-indexed: seat_nr=0 is even, number_of_seats=2 is even
      # The validation should accept this because rem(2, 2) == 0 && rem(0, 2) == 0 (not 1)
      options2 = [
        # row 0, seat 0 to 1 (0-indexed), distance 0
        {0, 0, 1, 0}
      ]

      valid_options2 = SeatyReservation.Allocations.validate_options(location, options2)

      # This option should be valid
      assert length(valid_options2) == 1
      assert hd(valid_options2) == {0, 0, 1, 0}
    end
  end
end
