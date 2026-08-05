defmodule SeatyReservationWeb.AllocationController do
  use SeatyReservationWeb, :controller

  alias SeatyReservation.Events
  alias SeatyReservation.Allocations

  def create(conn, %{"event_id" => event_id}) do
    event = Events.get_event!(event_id)
    result = Allocations.allocate_event(event_id)
    reservations = SeatyReservation.Reservations.get_reservations_by_event(event_id)
    code_to_name = Map.new(reservations, &{&1.code, &1.name})
    result_with_names = %{assigned: Enum.map(result.assigned, &Map.put(&1, :name, code_to_name[&1.code])), unallocated: result.unallocated}

    render(conn, :show, event: event, result: result_with_names)
  end
end
