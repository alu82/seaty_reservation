defmodule SeatyReservationWeb.ProductionControllerTest do
  use SeatyReservationWeb.ConnCase

  import SeatyReservation.ProductionsFixtures

  @create_attrs %{name: "Test Production"}
  @update_attrs %{name: "Updated Production"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all productions", %{conn: conn} do
      conn =
        conn
        |> auth_conn()
        |> get(~p"/productions")

      assert html_response(conn, 200) =~ "Listing Productions"
    end
  end

  describe "new production" do
    test "renders form", %{conn: conn} do
      conn =
        conn
        |> auth_conn()
        |> get(~p"/productions/new")

      assert html_response(conn, 200) =~ "New Production"
    end
  end

  describe "create production" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        conn
        |> auth_conn()
        |> post(~p"/productions", production: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/productions/#{id}"

      conn = get(conn, ~p"/productions/#{id}")
      assert html_response(conn, 200) =~ "Production #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        conn
        |> auth_conn()
        |> post(~p"/productions", production: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Production"
    end
  end

  describe "edit production" do
    setup [:create_production]

    test "renders form for editing chosen production", %{conn: conn, production: production} do
      conn =
        conn
        |> auth_conn()
        |> get(~p"/productions/#{production}/edit")

      assert html_response(conn, 200) =~ "Edit Production"
    end
  end

  describe "update production" do
    setup [:create_production]

    test "redirects when data is valid", %{conn: conn, production: production} do
      conn =
        conn
        |> auth_conn()
        |> put(~p"/productions/#{production}", production: @update_attrs)

      assert redirected_to(conn) == ~p"/productions/#{production}"

      conn = get(conn, ~p"/productions/#{production}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, production: production} do
      conn =
        conn
        |> auth_conn()
        |> put(~p"/productions/#{production}", production: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Production"
    end
  end

  describe "delete production" do
    setup [:create_production]

    test "deletes chosen production", %{conn: conn, production: production} do
      conn =
        conn
        |> auth_conn()
        |> delete(~p"/productions/#{production}")

      assert redirected_to(conn) == ~p"/productions"

      assert_error_sent 404, fn ->
        get(conn, ~p"/productions/#{production}")
      end
    end
  end

  defp create_production(_) do
    production = production_fixture()
    %{production: production}
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
