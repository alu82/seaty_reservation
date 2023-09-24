defmodule SeatyReservationWeb.AllocationController do
  use SeatyReservationWeb, :controller

  alias SeatyReservation.Events
  alias SeatyReservation.Reservations
  alias SeatyReservation.Allocations

  def show(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    render(conn, :show, event: event)
  end

  def create(conn, %{"event_id" => event_id}) do
    reservations = Reservations.get_reservations_by_event(event_id)
    Allocations.create_allocation(reservations)

    conn
      |> redirect(to: ~p"/events")
  end
end
