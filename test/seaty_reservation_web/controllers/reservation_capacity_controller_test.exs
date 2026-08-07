defmodule SeatyReservationWeb.ReservationCapacityControllerTest do
  use SeatyReservationWeb.ConnCase
  import Swoosh.TestAssertions

  import SeatyReservation.ReservationsFixtures
  import SeatyReservation.EventsFixtures

  @valid_attrs %{
    "name" => "Test User",
    "seats" => "2",
    "contact" => "test@example.com"
  }

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

  describe "capacity guard in create" do
    test "create reservation fails when exceeding capacity", %{conn: conn} do
      event = event_fixture(%{total_seats: 10})

      # Fill up 8 seats
      reservation_fixture(%{"event_id" => event.id, "seats" => "8"})

      # Try to create reservation for 3 more seats (8 + 3 = 11 > 10)
      attrs =
        @valid_attrs |> Map.put("event_id", Integer.to_string(event.id)) |> Map.put("seats", "3")

      conn =
        conn
        |> auth_conn()
        |> post(~p"/reservations", reservation: attrs)

      # Should redirect back to new with error
      assert redirected_to(conn) == ~p"/reservations/new"
      # Check that an email was NOT sent (reservation failed)
      refute_email_sent()
    end

    test "create reservation succeeds when under capacity", %{conn: conn} do
      event = event_fixture(%{total_seats: 10})

      # Fill up 5 seats
      reservation_fixture(%{"event_id" => event.id, "seats" => "5"})

      # Try to create reservation for 4 more seats (5 + 4 = 9 <= 10)
      attrs =
        @valid_attrs |> Map.put("event_id", Integer.to_string(event.id)) |> Map.put("seats", "4")

      conn =
        conn
        |> auth_conn()
        |> post(~p"/reservations", reservation: attrs)

      # Should redirect to show
      redirected = redirected_to(conn)
      assert redirected =~ "/reservations/"
      assert redirected =~ "token="

      # Verify reservation was created
      {:email, _email} = assert_email_sent()
    end

    test "create reservation succeeds when exactly at capacity", %{conn: conn} do
      event = event_fixture(%{total_seats: 10})

      # Fill up 6 seats
      reservation_fixture(%{"event_id" => event.id, "seats" => "6"})

      # Try to create reservation for 4 more seats (6 + 4 = 10 = capacity)
      attrs =
        @valid_attrs |> Map.put("event_id", Integer.to_string(event.id)) |> Map.put("seats", "4")

      conn =
        conn
        |> auth_conn()
        |> post(~p"/reservations", reservation: attrs)

      # Should redirect to show
      redirected = redirected_to(conn)
      assert redirected =~ "/reservations/"
      assert redirected =~ "token="

      {:email, _email} = assert_email_sent()
    end

    test "create reservation fails without event_id", %{conn: conn} do
      attrs = @valid_attrs

      conn =
        conn
        |> auth_conn()
        |> post(~p"/reservations", reservation: attrs)

      assert redirected_to(conn) == ~p"/reservations/new"
      # Check that an email was NOT sent
      refute_email_sent()
    end
  end

  describe "capacity guard in update" do
    setup [:create_reservation_with_event]

    test "update reservation fails when exceeding capacity", %{
      conn: conn,
      reservation: reservation,
      event: event
    } do
      # Fill up the remaining seats (event has 10, reservation has 2, so 8 left)
      reservation_fixture(%{"event_id" => event.id, "seats" => "7"})

      # Now we have 2 + 7 = 9 seats reserved, 1 left
      # Try to update our reservation from 2 to 4 seats (would need 9 - 2 + 4 = 11 > 10)
      attrs =
        @valid_attrs |> Map.put("event_id", Integer.to_string(event.id)) |> Map.put("seats", "4")

      conn =
        conn
        |> auth_conn()
        |> put(~p"/reservations/#{reservation}", reservation: attrs)

      # Should redirect back to edit with error
      assert redirected_to(conn) == ~p"/reservations/#{reservation}/edit"
      # Check that an email was NOT sent
      refute_email_sent()
    end

    test "update reservation succeeds when under capacity", %{
      conn: conn,
      reservation: reservation,
      event: event
    } do
      # Fill up some seats (event has 10, reservation has 2, so 8 left)
      reservation_fixture(%{"event_id" => event.id, "seats" => "3"})

      # Now we have 2 + 3 = 5 seats reserved, 5 left
      # Try to update our reservation from 2 to 4 seats (5 - 2 + 4 = 7 <= 10)
      attrs =
        @valid_attrs |> Map.put("event_id", Integer.to_string(event.id)) |> Map.put("seats", "4")

      conn =
        conn
        |> auth_conn()
        |> put(~p"/reservations/#{reservation}", reservation: attrs)

      assert redirected_to(conn) == ~p"/reservations/?event_id=#{event.id}"
    end

    test "update reservation with resend_mail sends email", %{
      conn: conn,
      reservation: reservation,
      event: _event
    } do
      attrs =
        @valid_attrs
        |> Map.put("event_id", Integer.to_string(reservation.event_id))
        |> Map.put("resend_mail", "true")

      conn =
        conn
        |> auth_conn()
        |> put(~p"/reservations/#{reservation}", reservation: attrs)

      assert redirected_to(conn) == ~p"/reservations/?event_id=#{reservation.event_id}"
      {:email, email} = assert_email_sent()
      # Subject uses SY_MAIL_SUBJECT or default, just check it has the code
      assert email.subject =~ reservation.code
    end
  end

  describe "show with token" do
    setup [:create_reservation_with_event]

    test "show reservation with valid token", %{
      conn: conn,
      reservation: reservation,
      event: _event
    } do
      conn =
        conn
        |> get(~p"/reservations/#{reservation}?token=#{reservation.token}")

      assert html_response(conn, 200) =~ "Reservation"
    end

    test "show reservation with invalid token redirects", %{
      conn: conn,
      reservation: reservation,
      event: _event
    } do
      conn =
        conn
        |> get(~p"/reservations/#{reservation}?token=INVALID_TOKEN")

      assert redirected_to(conn) == ~p"/reservations/new"
      # Check that no email was sent
      refute_email_sent()
    end

    test "show reservation with missing token fails", %{conn: conn} do
      reservation = reservation_fixture()

      # Without token, this raises a FunctionClauseError (400)
      assert_error_sent 400, fn ->
        conn
        |> get(~p"/reservations/#{reservation}")
      end
    end
  end

  defp create_reservation_with_event(_) do
    event = event_fixture(%{total_seats: 10})
    reservation = reservation_fixture(%{"event_id" => event.id, "seats" => "2"})
    %{event: event, reservation: reservation}
  end
end
