defmodule SeatyReservationWeb.ReservationControllerTest do
  use SeatyReservationWeb.ConnCase

  import SeatyReservation.ReservationsFixtures

  @create_attrs %{code: "some code", name: "some name", group: 42, comment: "some comment", prio: 42, order_date: ~N[2023-09-10 21:24:00], contact: "some contact", preferred_row: "some preferred_row"}
  @update_attrs %{code: "some updated code", name: "some updated name", group: 43, comment: "some updated comment", prio: 43, order_date: ~N[2023-09-11 21:24:00], contact: "some updated contact", preferred_row: "some updated preferred_row"}
  @invalid_attrs %{code: nil, name: nil, group: nil, comment: nil, prio: nil, order_date: nil, contact: nil, preferred_row: nil}

  describe "index" do
    test "lists all reservations", %{conn: conn} do
      conn = get(conn, ~p"/reservations")
      assert html_response(conn, 200) =~ "Listing Reservations"
    end
  end

  describe "new reservation" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/reservations/new")
      assert html_response(conn, 200) =~ "New Reservation"
    end
  end

  describe "create reservation" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/reservations", reservation: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/reservations/#{id}"

      conn = get(conn, ~p"/reservations/#{id}")
      assert html_response(conn, 200) =~ "Reservation #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/reservations", reservation: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Reservation"
    end
  end

  describe "edit reservation" do
    setup [:create_reservation]

    test "renders form for editing chosen reservation", %{conn: conn, reservation: reservation} do
      conn = get(conn, ~p"/reservations/#{reservation}/edit")
      assert html_response(conn, 200) =~ "Edit Reservation"
    end
  end

  describe "update reservation" do
    setup [:create_reservation]

    test "redirects when data is valid", %{conn: conn, reservation: reservation} do
      conn = put(conn, ~p"/reservations/#{reservation}", reservation: @update_attrs)
      assert redirected_to(conn) == ~p"/reservations/#{reservation}"

      conn = get(conn, ~p"/reservations/#{reservation}")
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, reservation: reservation} do
      conn = put(conn, ~p"/reservations/#{reservation}", reservation: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Reservation"
    end
  end

  describe "delete reservation" do
    setup [:create_reservation]

    test "deletes chosen reservation", %{conn: conn, reservation: reservation} do
      conn = delete(conn, ~p"/reservations/#{reservation}")
      assert redirected_to(conn) == ~p"/reservations"

      assert_error_sent 404, fn ->
        get(conn, ~p"/reservations/#{reservation}")
      end
    end
  end

  defp create_reservation(_) do
    reservation = reservation_fixture()
    %{reservation: reservation}
  end
end
