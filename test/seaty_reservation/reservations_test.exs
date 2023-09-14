defmodule SeatyReservation.ReservationsTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Reservations

  describe "reservations" do
    alias SeatyReservation.Reservations.Reservation

    import SeatyReservation.ReservationsFixtures

    @invalid_attrs %{code: nil, name: nil, group: nil, comment: nil, prio: nil, contact: nil, preferred_row: nil}

    test "list_reservations/0 returns all reservations" do
      reservation = reservation_fixture()
      assert Reservations.list_reservations() == [reservation]
    end

    test "get_reservation!/1 returns the reservation with given id" do
      reservation = reservation_fixture()
      assert Reservations.get_reservation!(reservation.id) == reservation
    end

    test "create_reservation/1 with valid data creates a reservation" do
      valid_attrs = %{code: "some code", name: "some name", group: 42, comment: "some comment", prio: 42, contact: "some contact", preferred_row: "some preferred_row"}

      assert {:ok, %Reservation{} = reservation} = Reservations.create_reservation(valid_attrs)
      assert reservation.code == "some code"
      assert reservation.name == "some name"
      assert reservation.group == 42
      assert reservation.comment == "some comment"
      assert reservation.prio == 42
      assert reservation.contact == "some contact"
      assert reservation.preferred_row == "some preferred_row"
    end

    test "create_reservation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reservations.create_reservation(@invalid_attrs)
    end

    test "update_reservation/2 with valid data updates the reservation" do
      reservation = reservation_fixture()
      update_attrs = %{code: "some updated code", name: "some updated name", group: 43, comment: "some updated comment", prio: 43, contact: "some updated contact", preferred_row: "some updated preferred_row"}

      assert {:ok, %Reservation{} = reservation} = Reservations.update_reservation(reservation, update_attrs)
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
      assert {:error, %Ecto.Changeset{}} = Reservations.update_reservation(reservation, @invalid_attrs)
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

  describe "reservations" do
    alias SeatyReservation.Reservations.Reservation

    import SeatyReservation.ReservationsFixtures

    @invalid_attrs %{code: nil, name: nil, group: nil, comment: nil, prio: nil, contact: nil, preferred_row: nil}

    test "list_reservations/0 returns all reservations" do
      reservation = reservation_fixture()
      assert Reservations.list_reservations() == [reservation]
    end

    test "get_reservation!/1 returns the reservation with given id" do
      reservation = reservation_fixture()
      assert Reservations.get_reservation!(reservation.id) == reservation
    end

    test "create_reservation/1 with valid data creates a reservation" do
      valid_attrs = %{code: "some code", name: "some name", group: 42, comment: "some comment", prio: 42, contact: "some contact", preferred_row: "some preferred_row"}

      assert {:ok, %Reservation{} = reservation} = Reservations.create_reservation(valid_attrs)
      assert reservation.code == "some code"
      assert reservation.name == "some name"
      assert reservation.group == 42
      assert reservation.comment == "some comment"
      assert reservation.prio == 42
      assert reservation.contact == "some contact"
      assert reservation.preferred_row == "some preferred_row"
    end

    test "create_reservation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reservations.create_reservation(@invalid_attrs)
    end

    test "update_reservation/2 with valid data updates the reservation" do
      reservation = reservation_fixture()
      update_attrs = %{code: "some updated code", name: "some updated name", group: 43, comment: "some updated comment", prio: 43, contact: "some updated contact", preferred_row: "some updated preferred_row"}

      assert {:ok, %Reservation{} = reservation} = Reservations.update_reservation(reservation, update_attrs)
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
      assert {:error, %Ecto.Changeset{}} = Reservations.update_reservation(reservation, @invalid_attrs)
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
