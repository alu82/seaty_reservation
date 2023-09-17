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
    changeset = Reservations.change_reservation(%Reservation{})
    render(conn, :new, changeset: changeset, events: get_events_for_dropdown())
  end

  def create(conn, %{"reservation" => reservation_params}) do
    event = Events.get_event!(reservation_params["event_id"])
    number_of_reservations = Reservations.get_reservation_count(reservation_params["event_id"])

    if event.total_seats > number_of_reservations + String.to_integer(reservation_params["seats"]) do
      case Reservations.create_reservation(reservation_params) do
        {:ok, reservation} ->
          ReservationEmail.confirmation(reservation, event) |> Mailer.deliver()
          conn
          |> put_flash(:info, gettext("Reservierung erfolgreich angelegt."))
          |> redirect(to: ~p"/reservations/#{reservation}?token=#{reservation.token}")

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, :new, changeset: changeset, events: get_events_for_dropdown())
      end
    else
      conn
      |> put_flash(:error, gettext("Zu wenig verfügbare Plätze. Bitte wählen Sie eine andere Aufführung."))
      |> redirect(to: ~p"/reservations/new")
    end
  end

  def show(conn, %{"id" => id, "token" => token}) do
    reservation = Reservations.get_reservation!(id)
    if reservation.token == token do
      event = Events.get_event!(reservation.event_id)
      render(conn, :show, reservation: reservation, event: event)
    else
      conn
      |> put_flash(:error, gettext("Reservierung nicht vorhanden oder kein Zugriff."))
      |> redirect(to: ~p"/reservations/new")
    end

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
        if reservation_params["resend_mail"] == "true" do
          event = Events.get_event!(reservation_params["event_id"])
          ReservationEmail.confirmation(reservation, event) |> Mailer.deliver()
        end

        conn
        |> put_flash(:info, "Reservation #{reservation.code} updated successfully.")
        |> redirect(to: ~p"/reservations")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, reservation: reservation, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    reservation = Reservations.get_reservation!(id)
    {:ok, reservation} = Reservations.delete_reservation(reservation)

    conn
    |> put_flash(:info, "Reservation #{reservation.code} deleted successfully.")
    |> redirect(to: ~p"/reservations")
  end

  defp get_events_for_dropdown() do
    Enum.map(
      Events.get_all_active(),
      fn ev-> {ev.datetime, ev.id} end
    )
  end
end
