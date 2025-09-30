defmodule SeatyReservationWeb.ReservationController do
  use SeatyReservationWeb, :controller

  alias SeatyReservation.Reservations
  alias SeatyReservation.Reservations.Reservation
  alias SeatyReservation.Events
  alias SeatyReservation.ReservationEmail
  alias SeatyReservation.Mailer

  def index(conn, %{"event_id" => event_id}) do
    reservations = Reservations.get_reservations_by_event(event_id)
    events = Events.get_all_future()
    render(conn, :index, reservations: reservations, events: events)
  end

  def index(conn, _params) do
    reservations = Reservations.list_reservations()
    events = Events.get_all_future()
    render(conn, :index, reservations: reservations, events: events)
  end

  def index_csv(conn, _params) do
    reservations = Reservations.list_reservations()

    csv_data = convert_to_csv(reservations)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"reservations.csv\"")
    |> send_resp(200, csv_data)

  end

  def new(conn, _params) do
    changeset = Reservations.change_reservation(%Reservation{})
    render(conn, :new, changeset: changeset, events: get_events_for_dropdown())
  end

  def create(conn, %{"reservation" => reservation_params}) do
    event_id = reservation_params["event_id"]

    # Check if event_id is present and valid
    cond do

      is_nil(event_id) or event_id == "" ->
        conn
        |> put_flash(:error, gettext("Bitte wählen Sie eine Aufführung aus."))
        |> redirect(to: ~p"/reservations/new")

      true ->
        event = Events.get_event!(event_id)
        number_of_reservations = Reservations.get_reservation_count(event_id)
        reservations_seats = if reservation_params["seats"] == "" do 0 else String.to_integer(reservation_params["seats"]) end

        if event.total_seats >= number_of_reservations + reservations_seats do
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
    events = get_events_for_dropdown()
    reservation = Reservations.get_reservation!(id)
    changeset = Reservations.change_reservation(reservation)
    render(conn, :edit, reservation: reservation, changeset: changeset, events: events)
  end

  def update(conn, %{"id" => id, "reservation" => reservation_params}) do
    reservation = Reservations.get_reservation!(id)
    event = Events.get_event!(reservation_params["event_id"])
    number_of_reservations = Reservations.get_reservation_count(reservation_params["event_id"])
    new_reservations_seats = if reservation_params["seats"] == "" do 0 else String.to_integer(reservation_params["seats"]) end

    #to calculate the total seats after the update, we have to know the old number of seats
    next_total_seats = number_of_reservations - reservation.seats + new_reservations_seats
    if event.total_seats >= next_total_seats do
      case Reservations.update_reservation(reservation, reservation_params) do
        {:ok, reservation} ->
          if reservation_params["resend_mail"] == "true" do
            event = Events.get_event!(reservation_params["event_id"])
            ReservationEmail.confirmation(reservation, event) |> Mailer.deliver()
          end

          conn
          |> put_flash(:info, "Reservation #{reservation.code} updated successfully.")
          |> redirect(to: ~p"/reservations/?event_id=#{event.id}")

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, :edit, reservation: reservation, changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, gettext("Zu wenig verfügbare Plätze. Bitte wählen Sie eine andere Aufführung."))
      |> redirect(to: ~p"/reservations/#{id}/edit")
    end
  end

  def cancel(conn, %{"id" => id}) do
    reservation = Reservations.get_reservation!(id)

    case Reservations.update_reservation(reservation, %{"seats" => 0, "internal_comment" => "storniert", "prio" => 0}) do
      {:ok, reservation} ->
        # Send confirmation email with the updated reservation (0 seats)
        event = Events.get_event!(reservation.event_id)
        ReservationEmail.confirmation(reservation, event) |> Mailer.deliver()

        conn
        |> put_flash(:info, "Reservation #{reservation.code} cancelled successfully and confirmation email sent.")
        |> redirect(to: ~p"/reservations/#{id}/edit")

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
      Events.get_all_future(),
      fn ev->
        reserved_seats = Reservations.get_reservation_count(ev.id)
        total_seats = ev.total_seats
        reservable_seats = total_seats - reserved_seats
        {ev.datetime, reservable_seats, ev.active, ev.id}
      end
    )
  end

  defp convert_to_csv(reservations) do
    # Define the headers for the CSV file
    headers = [
      "id",
      "event_id",
      "code",
      "prio",
      "seats",
      "name",
      "contact",
      "group",
      "preferred_row",
      "comment",
      "internal_comment",
      "token",
      "inserted_at"
    ]

    # Prepare the rows of data (mapping each reservation to a list of values)
    rows = Enum.map(reservations, fn reservation ->
      %{
        "id" => reservation.id,
        "event_id" => reservation.event_id,
        "code" => reservation.code,
        "prio" => reservation.prio,
        "seats" => reservation.seats,
        "name" => reservation.name,
        "contact" => reservation.contact,
        "group" => reservation.group,
        "preferred_row" => reservation.preferred_row,
        "comment" => reservation.comment,
        "internal_comment" => reservation.internal_comment,
        "token" => reservation.token,
        "inserted_at" => reservation.inserted_at
      }
    end)

    # Use the CSV library to generate the CSV data with proper handling of special characters
    # CSV.encode/1 returns an enumerable that you can convert to a string
    rows
    |> CSV.encode(headers: headers, separator: ?;)
    |> Enum.join()                        # Join the CSV rows with newlines
  end

end
