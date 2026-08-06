defmodule SeatyReservationWeb.AllocationController do
  use SeatyReservationWeb, :controller
  alias SeatyReservation.Allocations

  def create(conn, %{"event_id" => event_id}) do
    case Allocations.persist_allocation(event_id) do
      {:ok, _allocation} ->
        conn
        |> put_flash(:info, "Allocation created successfully.")
        |> redirect(to: ~p"/events/#{event_id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to create allocation.")
        |> redirect(to: ~p"/events/#{event_id}")
    end
  end

  def show(conn, %{"event_id" => _event_id, "id" => id}) do
    allocation = Allocations.get_allocation!(id) |> SeatyReservation.Repo.preload(:event)
    is_up_to_date = Allocations.is_up_to_date(allocation)
    fully_allocated = Allocations.fully_allocated?(allocation)
    reservations = SeatyReservation.Reservations.get_reservations_by_event(allocation.event_id)
    code_to_name = Map.new(reservations, &{&1.code, &1.name})

    result = allocation.result
    result_with_names = %{
      assigned: Enum.map(result["assigned"], fn entry ->
        entry
        |> Map.put(:name, code_to_name[entry["code"]])
        |> Enum.into(%{}, fn {k, v} ->
          key = if is_binary(k), do: String.to_atom(k), else: k
          {key, v}
        end)
      end),
      unallocated: Enum.map(result["unallocated"], fn entry ->
        entry
        |> Map.put(:name, code_to_name[entry["code"]])
        |> Enum.into(%{}, fn {k, v} ->
          key = if is_binary(k), do: String.to_atom(k), else: k
          {key, v}
        end)
      end)
    }

    render(conn, :show, allocation: allocation, is_up_to_date: is_up_to_date, fully_allocated: fully_allocated, result: result_with_names)
  end

  def delete(conn, %{"event_id" => event_id, "id" => id}) do
    allocation = Allocations.get_allocation!(id)

    case Allocations.delete_allocation(allocation) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Allocation deleted successfully.")
        |> redirect(to: ~p"/events/#{event_id}")

      {:error, _} ->
        conn
        |> put_flash(:error, "Failed to delete allocation.")
        |> redirect(to: ~p"/events/#{event_id}")
    end
  end
end
