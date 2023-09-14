defmodule SeatyReservationWeb.ReservationController do
  use SeatyReservationWeb, :controller

  alias SeatyReservation.Reservations
  alias SeatyReservation.Reservations.Reservation
  alias SeatyReservation.Events
  alias SeatyReservation.ReservationEmail
  alias SeatyReservation.Mailer

  def index(conn, _params) do
    reservations = Reservations.list_reservations()
    render(conn, :index, reservations: reservations)
  end

  def new(conn, _params) do
    events = Enum.map(
      Events.get_all_active(),
      fn ev-> {ev.datetime, ev.id} end
    )
    changeset = Reservations.change_reservation(%Reservation{})
    render(conn, :new, changeset: changeset, events: events)
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"reservation" => reservation_params}) do
    case Reservations.create_reservation(reservation_params) do
      {:ok, reservation} ->
        ReservationEmail.confirmation() |> Mailer.deliver()
        conn
        |> put_flash(:info, "Reservation created successfully.")
        |> redirect(to: ~p"/reservations/#{reservation}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    reservation = Reservations.get_reservation!(id)
    render(conn, :show, reservation: reservation)
  end

  def edit(conn, %{"id" => id}) do
    events = Enum.map(
      Events.get_all_active(),
      fn ev-> {ev.datetime, ev.id} end
    )
    reservation = Reservations.get_reservation!(id)
    changeset = Reservations.change_reservation(reservation)
    render(conn, :edit, reservation: reservation, changeset: changeset, events: events)
  end

  def update(conn, %{"id" => id, "reservation" => reservation_params}) do
    reservation = Reservations.get_reservation!(id)

    case Reservations.update_reservation(reservation, reservation_params) do
      {:ok, reservation} ->
        conn
        |> put_flash(:info, "Reservation updated successfully.")
        |> redirect(to: ~p"/reservations/#{reservation}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, reservation: reservation, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    reservation = Reservations.get_reservation!(id)
    {:ok, _reservation} = Reservations.delete_reservation(reservation)

    conn
    |> put_flash(:info, "Reservation deleted successfully.")
    |> redirect(to: ~p"/reservations")
  end
end
