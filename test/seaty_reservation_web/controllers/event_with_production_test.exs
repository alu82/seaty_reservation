defmodule SeatyReservationWeb.EventWithProductionTest do
  use SeatyReservationWeb.ConnCase

  import SeatyReservation.EventsFixtures
  import SeatyReservation.ProductionsFixtures

  describe "new event form" do
    test "includes production dropdown", %{conn: conn} do
      production = production_fixture()
      conn = conn |> auth_conn() |> get(~p"/events/new")

      assert html_response(conn, 200) =~ "Production"
      assert html_response(conn, 200) =~ production.name
    end
  end

  describe "create event" do
    test "creates event with selected production", %{conn: conn} do
      production = production_fixture()

      conn =
        conn
        |> auth_conn()
        |> post(~p"/events",
          event: %{
            active: "true",
            datetime: "2023-09-10 21:17:00",
            total_seats: "42",
            code: "A",
            production_id: to_string(production.id)
          }
        )

      assert redirected_to(conn) =~ ~p"/events/"
    end
  end

  describe "edit event form" do
    test "shows current production selection", %{conn: conn} do
      production = production_fixture()
      event = event_fixture(%{production_id: production.id})

      conn = conn |> auth_conn() |> get(~p"/events/#{event}/edit")

      assert html_response(conn, 200) =~ production.name
    end
  end

  describe "event index" do
    test "shows production name", %{conn: conn} do
      production = production_fixture()
      _event = event_fixture(%{production_id: production.id})

      conn = conn |> auth_conn() |> get(~p"/events")

      assert html_response(conn, 200) =~ production.name
    end
  end

  describe "event show" do
    test "shows production name", %{conn: conn} do
      production = production_fixture()
      event = event_fixture(%{production_id: production.id})

      conn = conn |> auth_conn() |> get(~p"/events/#{event}")

      assert html_response(conn, 200) =~ production.name
    end
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
