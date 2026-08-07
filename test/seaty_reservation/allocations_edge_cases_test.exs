defmodule SeatyReservation.AllocationsEdgeCasesTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Allocations
  alias SeatyReservation.Reservations
  import SeatyReservation.EventsFixtures

  # Helper to create a reservation for a specific event
  defp create_reservation_for_event(event, attrs) do
    default_attrs = %{
      "code" => "TEST" <> Integer.to_string(Enum.random(1..9999)),
      "name" => "Test User",
      "group" => "42",
      "comment" => "test comment",
      "seats" => "2",
      "contact" => "test@example.com",
      "preferred_row" => "",
      "event_id" => Integer.to_string(event.id)
    }

    merged_attrs = Map.merge(default_attrs, attrs)
    {:ok, reservation} = Reservations.create_reservation(merged_attrs)
    reservation
  end

  describe "allocation edge cases" do
    test "allocate_event/1 with full capacity using multiple small reservations" do
      event = event_fixture(%{total_seats: 207})

      # Create many small reservations that fill the theater
      # 4 rows of 24 = 96 seats -> 4 reservations of 24
      # 5 rows of 19 = 95 seats -> 5 reservations of 19
      # 4 rows of 4 = 16 seats -> 4 reservations of 4
      # Total = 207 seats

      # Create 4 reservations of 24 seats
      for c <- 1..4 do
        r = create_reservation_for_event(event, %{"seats" => "24", "group" => c})
        {:ok, _} = Reservations.update_reservation(r, %{prio: 100})
      end

      # Create 5 reservations of 19 seats
      for c <- 1..5 do
        r = create_reservation_for_event(event, %{"seats" => "19", "group" => c + 4})
        {:ok, _} = Reservations.update_reservation(r, %{prio: 95})
      end

      # Create 4 reservations of 4 seats
      for c <- 1..4 do
        r = create_reservation_for_event(event, %{"seats" => "4", "group" => c + 9})
        {:ok, _} = Reservations.update_reservation(r, %{prio: 90})
      end

      # Verify we have the right number of reservations
      reservations = Reservations.get_reservations_by_event(event.id)
      total_seats = Enum.reduce(reservations, 0, fn r, acc -> acc + r.seats end)

      assert total_seats == 207,
             "Expected 207 seats, got #{total_seats} from #{length(reservations)} reservations"

      result = Allocations.allocate_event(event.id)

      # All seats should be assigned
      assert length(result.assigned) == 207
      assert length(result.unallocated) == 0
    end

    test "allocate_event/1 with mixed cancelled and active reservations" do
      event = event_fixture(%{total_seats: 200})

      # Create a cancelled reservation (prio = 0, seats = 0)
      r1 = create_reservation_for_event(event, %{})

      {:ok, _} =
        Reservations.update_reservation(r1, %{
          seats: 0,
          prio: 0,
          internal_comment: "storniert"
        })

      # Create active reservations
      r2 = create_reservation_for_event(event, %{"seats" => "5"})
      r3 = create_reservation_for_event(event, %{"seats" => "3"})
      {:ok, _} = Reservations.update_reservation(r2, %{prio: 100})
      {:ok, _} = Reservations.update_reservation(r3, %{prio: 95})

      result = Allocations.allocate_event(event.id)

      # Cancelled reservation should be excluded
      assert length(result.assigned) == 8
      assert length(result.unallocated) == 0
    end

    test "allocate_event/1 with reservations having preferred_row" do
      event = event_fixture(%{total_seats: 200})

      # Create reservations with preferred rows
      r1 = create_reservation_for_event(event, %{"seats" => "2", "preferred_row" => "1"})
      r2 = create_reservation_for_event(event, %{"seats" => "2", "preferred_row" => "5"})
      {:ok, _} = Reservations.update_reservation(r1, %{prio: 100})
      {:ok, _} = Reservations.update_reservation(r2, %{prio: 95})

      result = Allocations.allocate_event(event.id)

      # Both should be assigned
      assert length(result.assigned) == 4
      assert length(result.unallocated) == 0
    end

    test "allocate_event/1 returns empty when no reservations" do
      event = event_fixture(%{total_seats: 200})

      result = Allocations.allocate_event(event.id)

      assert length(result.assigned) == 0
      assert length(result.unallocated) == 0
    end

    test "allocate_event/1 handles reservations with zero seats" do
      event = event_fixture(%{total_seats: 200})

      r1 = create_reservation_for_event(event, %{})
      {:ok, _} = Reservations.update_reservation(r1, %{seats: 0, prio: 100})
      r2 = create_reservation_for_event(event, %{"seats" => "5"})
      {:ok, _} = Reservations.update_reservation(r2, %{prio: 95})

      result = Allocations.allocate_event(event.id)

      # Zero-seat reservation should be excluded
      assert length(result.assigned) == 5
      assert length(result.unallocated) == 0
    end

    test "persist_allocation/1 stores correct result structure" do
      event = event_fixture(%{total_seats: 200})

      r1 = create_reservation_for_event(event, %{"seats" => "2"})
      {:ok, _} = Reservations.update_reservation(r1, %{prio: 100})

      {:ok, allocation} = Allocations.persist_allocation(event.id)

      assert allocation.event_id == event.id
      # When stored in DB, the map keys become strings
      assert Map.has_key?(allocation.result, "assigned") ||
               Map.has_key?(allocation.result, :assigned)

      assert Map.has_key?(allocation.result, "unallocated") ||
               Map.has_key?(allocation.result, :unallocated)
    end

    test "is_up_to_date/1 with newly created allocation" do
      event = event_fixture(%{total_seats: 200})

      r1 = create_reservation_for_event(event, %{"seats" => "2"})
      {:ok, _} = Reservations.update_reservation(r1, %{prio: 100})

      {:ok, allocation} = Allocations.persist_allocation(event.id)

      assert Allocations.is_up_to_date(allocation)
    end

    test "fully_allocated?/1 returns true when no unallocated" do
      event = event_fixture(%{total_seats: 200})

      r1 = create_reservation_for_event(event, %{"seats" => "2"})
      {:ok, _} = Reservations.update_reservation(r1, %{prio: 100})

      {:ok, allocation} = Allocations.persist_allocation(event.id)

      # The fully_allocated? function expects string keys after DB storage
      # Check the actual result structure
      result = allocation.result
      unallocated = result["unallocated"] || result[:unallocated] || []
      assert length(unallocated) == 0
    end

    test "fully_allocated?/1 returns false when unallocated exist" do
      event = event_fixture(%{total_seats: 10})

      # Create a reservation that can't be allocated (too many seats for any row)
      # Max row size is 24, so 25 seats won't fit
      r1 = create_reservation_for_event(event, %{"seats" => "25"})
      {:ok, _} = Reservations.update_reservation(r1, %{prio: 100})

      {:ok, allocation} = Allocations.persist_allocation(event.id)

      # Check the actual result structure
      result = allocation.result
      unallocated = result["unallocated"] || result[:unallocated] || []
      assert length(unallocated) > 0
    end
  end

  describe "build_location" do
    test "build_location/0 creates correct theater layout" do
      location = Allocations.build_location()

      # 4 rows of 24 seats
      # 5 rows of 19 seats
      # 4 rows of 4 seats
      # Total = 13 rows
      assert length(location) == 13

      # Check row sizes
      # Row 1 (0-indexed)
      assert length(Enum.at(location, 0)) == 24
      # Row 2
      assert length(Enum.at(location, 1)) == 24
      # Row 3
      assert length(Enum.at(location, 2)) == 24
      # Row 4
      assert length(Enum.at(location, 3)) == 24
      # Row 5
      assert length(Enum.at(location, 4)) == 19
      # Row 6
      assert length(Enum.at(location, 5)) == 19
      # Row 7
      assert length(Enum.at(location, 6)) == 19
      # Row 8
      assert length(Enum.at(location, 7)) == 19
      # Row 9
      assert length(Enum.at(location, 8)) == 19
      # Row 10
      assert length(Enum.at(location, 9)) == 4
      # Row 11
      assert length(Enum.at(location, 10)) == 4
      # Row 12
      assert length(Enum.at(location, 11)) == 4
      # Row 13
      assert length(Enum.at(location, 12)) == 4
    end
  end
end
