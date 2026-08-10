defmodule SeatyReservation.Authorization do
  alias SeatyReservation.Allocations.Allocation
  alias SeatyReservation.Events.Event
  alias SeatyReservation.Productions.Production
  alias SeatyReservation.Reservations.Reservation
  alias SeatyReservation.Users.User

  defstruct role: nil, show: %{}, index: %{}, create: %{}, update: %{}, delete: %{}

  def can(:user) do
    grant(:user)
    |> create(Reservation)
    |> show(Reservation)
  end

  def can(:reader) do
    grant(:reader)
    |> create(Reservation)
    |> show(Reservation)
    |> index(Reservation)
    |> show(Production)
    |> index(Production)
    |> show(Event)
    |> index(Event)
    |> show(Allocation)
    |> index(Allocation)
  end

  def can(:editor) do
    grant(:editor)
    |> all(Reservation)
    |> all(Production)
    |> all(Event)
    |> all(Allocation)
  end

  def can(:admin) do
    grant(:admin)
    |> all(Reservation)
    |> all(Production)
    |> all(Event)
    |> all(Allocation)
    |> all(User)
  end

  def grant(role), do: %__MODULE__{role: role}

  def show(authorization, resource), do: put_action(authorization, :show, resource)
  def index(authorization, resource), do: put_action(authorization, :index, resource)
  def create(authorization, resource), do: put_action(authorization, :create, resource)
  def update(authorization, resource), do: put_action(authorization, :update, resource)
  def delete(authorization, resource), do: put_action(authorization, :delete, resource)

  def all(authorization, resource) do
    authorization
    |> show(resource)
    |> index(resource)
    |> create(resource)
    |> update(resource)
    |> delete(resource)
  end

  def show?(authorization, resource), do: allowed?(authorization, :show, resource)
  def index?(authorization, resource), do: allowed?(authorization, :index, resource)
  def create?(authorization, resource), do: allowed?(authorization, :create, resource)
  def update?(authorization, resource), do: allowed?(authorization, :update, resource)
  def delete?(authorization, resource), do: allowed?(authorization, :delete, resource)

  defp allowed?(authorization, action, resource) do
    authorization
    |> Map.get(action)
    |> Map.get(resource, false)
  end

  defp put_action(authorization, action, resource) do
    permissions =
      authorization
      |> Map.get(action)
      |> Map.put(resource, true)

    Map.put(authorization, action, permissions)
  end
end
