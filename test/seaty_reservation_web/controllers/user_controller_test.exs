defmodule SeatyReservationWeb.UserControllerTest do
  use SeatyReservationWeb.ConnCase

  import SeatyReservation.UsersFixtures

  @create_attrs %{email: "test@example.com", password: "password123456789012", role: :user}
  @update_attrs %{email: "updated@example.com", role: :editor}
  @invalid_attrs %{email: nil}

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn =
        conn
        |> auth_conn()
        |> get(~p"/users")

      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn =
        conn
        |> auth_conn()
        |> get(~p"/users/new")

      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        conn
        |> auth_conn()
        |> post(~p"/users", user: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/users/#{id}"

      conn = get(conn, ~p"/users/#{id}")
      assert html_response(conn, 200) =~ "User #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        conn
        |> auth_conn()
        |> post(~p"/users", user: @invalid_attrs)

      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn =
        conn
        |> auth_conn()
        |> get(~p"/users/#{user}/edit")

      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn =
        conn
        |> auth_conn()
        |> put(~p"/users/#{user}", user: @update_attrs)

      assert redirected_to(conn) == ~p"/users/#{user}"

      conn = get(conn, ~p"/users/#{user}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        conn
        |> auth_conn()
        |> put(~p"/users/#{user}", user: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn =
        conn
        |> auth_conn()
        |> delete(~p"/users/#{user}")

      assert redirected_to(conn) == ~p"/users"

      assert_error_sent 404, fn ->
        get(conn, ~p"/users/#{user}")
      end
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
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
