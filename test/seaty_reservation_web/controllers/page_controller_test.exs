defmodule SeatyReservationWeb.PageControllerTest do
  use SeatyReservationWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Neue Reservierung anlegen"
  end

  test "home page links to publicly served browser and home screen icons", %{conn: conn} do
    html = conn |> get(~p"/") |> html_response(200) |> Floki.parse_document!()
    links = Floki.find(html, "link[rel=icon], link[rel=apple-touch-icon]")

    assert length(links) == 3

    for link <- links do
      [path] = Floki.attribute(link, "href")
      icon_conn = get(build_conn(), path)
      assert icon_conn.status == 200
      assert byte_size(icon_conn.resp_body) > 0
    end
  end
end
