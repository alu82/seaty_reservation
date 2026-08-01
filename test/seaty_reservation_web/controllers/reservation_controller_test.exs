defmodule SeatyReservationWeb.ReservationControllerTest do
  use SeatyReservationWeb.ConnCase

  import SeatyReservation.ReservationsFixtures
  import SeatyReservation.EventsFixtures

  import Swoosh.TestAssertions

  @create_attrs %{"code" => "some code", "name" => "some name", "seats" => "2", "group" => "42", "comment" => "some comment", "prio" => "42", "contact" => "test@example.com", "preferred_row" => "some preferred_row"}
  @update_attrs %{"code" => "some updated code", "name" => "some updated name", "seats" => "3", "group" => "43", "comment" => "some updated comment", "prio" => "43", "contact" => "test@example.com", "preferred_row" => "some preferred_row"}
  @invalid_attrs %{"code" => "", "name" => "", "group" => "", "comment" => "", "prio" => "", "contact" => "", "preferred_row" => "", "seats" => ""}

  describe "index" do
    test "lists all reservations", %{conn: conn} do
      conn =
        conn
        |> auth_conn()
        |> get(~p"/reservations")

      assert html_response(conn, 200) =~ "Listing Reservations"
    end
  end

  describe "new reservation" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/reservations/new")
      assert html_response(conn, 200) =~ "Neue Reservierung anlegen"
    end
  end

  describe "create reservation" do
    test "redirects to show when data is valid", %{conn: conn} do
      event = event_fixture()
      attrs =
        @create_attrs
        |> Map.put("event_id", Integer.to_string(event.id))

      conn = post(conn, ~p"/reservations", reservation: attrs)

      redirected = redirected_to(conn)
      assert redirected =~ "/reservations/"
      assert redirected =~ "token="

      conn = get(conn, redirected)
      assert html_response(conn, 200) =~ "Reservation"

      {:email, email} = assert_email_sent()
      assert email.subject =~ "Reservierungsnummer"
      refute email.subject =~ "storniert"
      assert email.to == [{"some name", "test@example.com"}]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/reservations", reservation: @invalid_attrs)
      assert redirected_to(conn) == ~p"/reservations/new"
    end
  end

  describe "edit reservation" do
    setup [:create_reservation]

    test "renders form for editing chosen reservation", %{conn: conn, reservation: reservation} do
      conn =
        conn
        |> auth_conn()
        |> get(~p"/reservations/#{reservation}/edit")

      assert html_response(conn, 200) =~ "Edit Reservation"
    end
  end

  describe "update reservation" do
    setup [:create_reservation]

    test "redirects when data is valid", %{conn: conn, reservation: reservation} do

      attrs =
        @update_attrs
        |> Map.put("event_id", Integer.to_string(reservation.event_id))

      conn =
        conn
        |> auth_conn()
        |> put(~p"/reservations/#{reservation}", reservation: attrs)

      assert redirected_to(conn) == ~p"/reservations/?event_id=#{reservation.event_id}"

      conn = get(conn, ~p"/reservations/#{reservation}?token=#{reservation.token}")
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, reservation: reservation} do

      attrs =
        @invalid_attrs
        |> Map.put("event_id", Integer.to_string(reservation.event_id))

      conn =
        conn
        |> auth_conn()
        |> put(~p"/reservations/#{reservation}", reservation: attrs)

      assert html_response(conn, 200) =~ "Edit Reservation"
    end
  end

  describe "delete reservation" do
    setup [:create_reservation]

    test "deletes chosen reservation", %{conn: conn, reservation: reservation} do
      conn =
        conn
        |> auth_conn()
        |> delete(~p"/reservations/#{reservation}")

      assert redirected_to(conn) == ~p"/reservations"

      assert_error_sent 404, fn ->
        get(conn, ~p"/reservations/#{reservation}?token=#{reservation.token}")
      end
    end
  end

  describe "cancel reservation" do
    setup [:create_reservation]

    test "cancels reservation and sends cancellation email", %{conn: conn, reservation: reservation} do
      conn =
        conn
        |> auth_conn()
        |> patch(~p"/reservations/#{reservation}/cancel")

      assert redirected_to(conn) == ~p"/reservations/#{reservation}/edit"

      conn = get(conn, redirected_to(conn))
      assert html_response(conn, 200) =~ "cancelled successfully and cancellation email sent"

      {:email, email} = assert_email_sent()
      assert email.subject =~ "Reservierung storniert"
      assert email.subject =~ to_string(reservation.code)
      assert email.to == [{reservation.name, reservation.contact}]
    end
  end

  defp create_reservation(_) do
    reservation = reservation_fixture()
    %{reservation: reservation}
  end

  defp auth_conn(conn) do
    basic_auth = Application.get_env(:seaty_reservation, :basic_auth)

    username = basic_auth[:username]
    password = basic_auth[:password]

    put_req_header(
      conn,
      "authorization",
      "Basic " <> Base.encode64("#{username}:#{password}")
    )
  end
end
