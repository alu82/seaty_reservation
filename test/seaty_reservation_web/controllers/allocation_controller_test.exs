defmodule SeatyReservationWeb.AllocationControllerTest do
  use SeatyReservationWeb.ConnCase

  alias SeatyReservation.Allocations
  alias SeatyReservation.Reservations
  import SeatyReservation.EventsFixtures

  test "shows cards for active reservations only", %{conn: conn} do
    event = event_fixture()

    {:ok, active} =
      Reservations.create_reservation(%{
        event_id: event.id,
        name: "Active Guest",
        contact: "active@example.com",
        seats: 2,
        internal_comment: "Needs aisle seat"
      })

    {:ok, cancelled} =
      Reservations.create_reservation(%{
        event_id: event.id,
        name: "Cancelled Guest",
        contact: "cancelled@example.com",
        seats: 0
      })

    {:ok, allocation} = Allocations.persist_allocation(event.id)

    html =
      conn
      |> reader_conn()
      |> get(~p"/events/#{event}/allocations/#{allocation}")
      |> html_response(200)

    assert html =~ "Reservation Cards"
    assert html =~ active.code
    assert html =~ "2"
    assert html =~ "Active Guest"
    assert html =~ "Needs aisle seat"
    refute html =~ cancelled.code
    refute html =~ "Cancelled Guest"
  end
end
