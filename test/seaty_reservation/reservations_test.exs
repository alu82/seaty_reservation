defmodule SeatyReservation.ReservationsTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Reservations

  describe "reservations" do
    alias SeatyReservation.Reservations.Reservation

    import SeatyReservation.ReservationsFixtures
    import SeatyReservation.EventsFixtures

    @invalid_attrs %{
      code: nil,
      name: nil,
      group: nil,
      comment: nil,
      prio: nil,
      contact: nil,
      preferred_row: nil
    }

    test "list_reservations/0 returns all reservations" do
      reservation = reservation_fixture()
      assert Reservations.list_reservations() == [reservation]
    end

    test "get_reservation!/1 returns the reservation with given id" do
      reservation = reservation_fixture()
      assert Reservations.get_reservation!(reservation.id) == reservation
    end

    test "create_reservation/1 with valid data creates a reservation" do
      event = event_fixture()

      valid_attrs = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "some name",
        "seats" => "2",
        "group" => "42",
        "comment" => "some comment",
        "contact" => "some contact",
        "preferred_row" => "some preferred_row"
      }

      assert {:ok, %Reservation{} = reservation} = Reservations.create_reservation(valid_attrs)
      assert reservation.event_id == 1
      assert reservation.name == "some name"
      assert reservation.group == 42
      assert reservation.comment == "some comment"
      assert reservation.contact == "some contact"
      assert reservation.preferred_row == "some preferred_row"
      assert reservation.code != nil
      assert reservation.prio != nil
      assert reservation.token != nil
    end
    test "create_reservation/1 generates code with event code prefix" do
      event = event_fixture(%{code: "ABC"})

      valid_attrs = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "some name",
        "seats" => "2",
        "contact" => "test@example.com"
      }

      assert {:ok, %Reservation{} = reservation} = Reservations.create_reservation(valid_attrs)
      assert String.starts_with?(reservation.code, "ABC")
      assert String.length(reservation.code) == 7  # ABC + 0001 (4 digits)
    end

    test "create_reservation/1 generates sequential codes" do
      event = event_fixture(%{code: "XYZ"})

      # Create first reservation
      attrs1 = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "name1",
        "seats" => "1",
        "contact" => "contact1@example.com"
      }
      assert {:ok, %Reservation{code: code1}} = Reservations.create_reservation(attrs1)

      # Create second reservation
      attrs2 = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "name2",
        "seats" => "1",
        "contact" => "contact2@example.com"
      }
      assert {:ok, %Reservation{code: code2}} = Reservations.create_reservation(attrs2)

      # Verify codes are sequential
      assert code1 == "XYZ0001"
      assert code2 == "XYZ0002"
    end

    test "create_reservation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reservations.create_reservation(@invalid_attrs)
    end

    test "update_reservation/2 with valid data updates the reservation" do
      reservation = reservation_fixture()

      update_attrs = %{
        code: "some updated code",
        name: "some updated name",
        group: 43,
        comment: "some updated comment",
        prio: 43,
        contact: "some updated contact",
        preferred_row: "some updated preferred_row"
      }

      assert {:ok, %Reservation{} = reservation} =
               Reservations.update_reservation(reservation, update_attrs)

      assert reservation.code == "some updated code"
      assert reservation.name == "some updated name"
      assert reservation.group == 43
      assert reservation.comment == "some updated comment"
      assert reservation.prio == 43
      assert reservation.contact == "some updated contact"
      assert reservation.preferred_row == "some updated preferred_row"
    end

    test "update_reservation/2 with invalid data returns error changeset" do
      reservation = reservation_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Reservations.update_reservation(reservation, @invalid_attrs)

      assert reservation == Reservations.get_reservation!(reservation.id)
    end

    test "delete_reservation/1 deletes the reservation" do
      reservation = reservation_fixture()
      assert {:ok, %Reservation{}} = Reservations.delete_reservation(reservation)
      assert_raise Ecto.NoResultsError, fn -> Reservations.get_reservation!(reservation.id) end
    end

    test "change_reservation/1 returns a reservation changeset" do
      reservation = reservation_fixture()
      assert %Ecto.Changeset{} = Reservations.change_reservation(reservation)
    end
  end
end
