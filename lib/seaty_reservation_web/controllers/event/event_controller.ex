defmodule SeatyReservationWeb.EventController do
  use SeatyReservationWeb, :controller

  alias SeatyReservation.Events
  alias SeatyReservation.Events.Event
  alias SeatyReservation.Reservations
  alias SeatyReservation.Productions

  def index(conn, _params) do
    events = Events.list_events()
    reservations = Reservations.get_reservation_count()
    render(conn, :index, events: events, reservations: reservations)
  end

  def new(conn, _params) do
    changeset = Events.change_event(%Event{})
    productions = Productions.list_productions() |> Enum.map(&{&1.name, &1.id})
    render(conn, :new, changeset: changeset, productions: productions)
  end

  def create(conn, %{"event" => event_params}) do
    case Events.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: ~p"/events/#{event}")

      {:error, %Ecto.Changeset{} = changeset} ->
        productions = Productions.list_productions() |> Enum.map(&{&1.name, &1.id})
        render(conn, :new, changeset: changeset, productions: productions)
    end
  end

  def show(conn, %{"id" => id}) do
    event = Events.get_event!(id, preload: [:production])
    render(conn, :show, event: event)
  end

  def edit(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    changeset = Events.change_event(event)
    productions = Productions.list_productions() |> Enum.map(&{&1.name, &1.id})
    render(conn, :edit, event: event, changeset: changeset, productions: productions)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Events.get_event!(id)

    case Events.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: ~p"/events/#{event}")

      {:error, %Ecto.Changeset{} = changeset} ->
        productions = Productions.list_productions() |> Enum.map(&{&1.name, &1.id})
        render(conn, :edit, event: event, changeset: changeset, productions: productions)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    {:ok, _event} = Events.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: ~p"/events")
  end
end
