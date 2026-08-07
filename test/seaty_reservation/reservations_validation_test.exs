defmodule SeatyReservation.ReservationsValidationTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Reservations
  import SeatyReservation.ReservationsFixtures
  import SeatyReservation.EventsFixtures

  describe "reservation validation" do
    test "create_reservation/1 requires name" do
      event = event_fixture()

      attrs = %{
        "event_id" => Integer.to_string(event.id),
        "seats" => "2",
        "contact" => "test@example.com"
      }

      assert {:error, %Ecto.Changeset{}} = Reservations.create_reservation(attrs)
    end

    test "create_reservation/1 requires contact" do
      event = event_fixture()

      attrs = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "Test User",
        "seats" => "2"
      }

      assert {:error, %Ecto.Changeset{}} = Reservations.create_reservation(attrs)
    end

    test "create_reservation/1 requires event_id" do
      attrs = %{
        "name" => "Test User",
        "seats" => "2",
        "contact" => "test@example.com"
      }

      assert {:error, %Ecto.Changeset{}} = Reservations.create_reservation(attrs)
    end

    test "create_reservation/1 requires seats" do
      event = event_fixture()

      attrs = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "Test User",
        "contact" => "test@example.com"
      }

      assert {:error, %Ecto.Changeset{}} = Reservations.create_reservation(attrs)
    end

    test "create_reservation/1 accepts valid minimal reservation" do
      event = event_fixture()

      attrs = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "Test User",
        "seats" => "2",
        "contact" => "test@example.com"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{}} =
               Reservations.create_reservation(attrs)
    end

    test "create_reservation/1 accepts reservation with all optional fields" do
      event = event_fixture()

      attrs = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "Test User",
        "seats" => "2",
        "contact" => "test@example.com",
        "group" => "42",
        "comment" => "Some comment",
        "preferred_row" => "5"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{}} =
               Reservations.create_reservation(attrs)
    end

    test "create_reservation/1 accepts seats as integer string" do
      event = event_fixture()

      attrs = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "Test User",
        "seats" => "5",
        "contact" => "test@example.com"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{seats: 5}} =
               Reservations.create_reservation(attrs)
    end

    test "create_reservation/1 accepts group as integer string" do
      event = event_fixture()

      attrs = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "Test User",
        "seats" => "2",
        "contact" => "test@example.com",
        "group" => "42"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{group: 42}} =
               Reservations.create_reservation(attrs)
    end

    test "update_reservation/2 with valid data succeeds" do
      reservation = reservation_fixture()

      attrs = %{
        name: "Updated Name",
        seats: 5,
        contact: "updated@example.com"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{}} =
               Reservations.update_reservation(reservation, attrs)
    end

    test "update_reservation/2 with invalid event_id raises constraint error" do
      reservation = reservation_fixture()

      attrs = %{
        event_id: -1
      }

      # This will raise a constraint error, not return an error changeset
      assert_raise Ecto.ConstraintError, fn ->
        Reservations.update_reservation(reservation, attrs)
      end
    end

    test "change_reservation/2 returns changeset" do
      reservation = reservation_fixture()

      changeset = Reservations.change_reservation(reservation)
      assert %Ecto.Changeset{} = changeset
    end

    test "change_reservation/2 with attrs returns changeset with attrs" do
      reservation = reservation_fixture()

      changeset = Reservations.change_reservation(reservation, %{name: "New Name"})
      assert %Ecto.Changeset{} = changeset
    end
  end

  describe "get_reservations_by_event" do
    test "get_reservations_by_event/1 returns reservations for event" do
      event = event_fixture()

      reservation1 = reservation_fixture(%{"event_id" => event.id})
      reservation2 = reservation_fixture(%{"event_id" => event.id})

      reservations = Reservations.get_reservations_by_event(event.id)

      assert length(reservations) == 2
      assert reservation1.id in Enum.map(reservations, & &1.id)
      assert reservation2.id in Enum.map(reservations, & &1.id)
    end

    test "get_reservations_by_event/1 returns empty list for event with no reservations" do
      event = event_fixture()

      reservations = Reservations.get_reservations_by_event(event.id)

      assert reservations == []
    end

    test "get_reservations_by_event/1 orders by priority descending" do
      event = event_fixture()

      r1 = reservation_fixture(%{"event_id" => event.id})
      r2 = reservation_fixture(%{"event_id" => event.id})
      r3 = reservation_fixture(%{"event_id" => event.id})

      # Set specific priorities
      {:ok, _} = Reservations.update_reservation(r1, %{prio: 50, group: 1})
      {:ok, _} = Reservations.update_reservation(r2, %{prio: 100, group: 2})
      {:ok, _} = Reservations.update_reservation(r3, %{prio: 75, group: 3})

      reservations = Reservations.get_reservations_by_event(event.id)

      # Should be ordered by prio descending
      assert length(reservations) == 3
      assert Enum.at(reservations, 0).prio == 100
      assert Enum.at(reservations, 1).prio == 75
      assert Enum.at(reservations, 2).prio == 50
    end
  end
end
