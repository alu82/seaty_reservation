defmodule SeatyReservation.ReservationEmail do
  use Phoenix.Swoosh,
    template_root: "lib/seaty_reservation_web/controllers/reservation/reservation_html",
    template_path: "mail"

  def confirmation(reservation, event) do
    mail_params = %{
      :name => reservation.name,
      :seats => reservation.seats,
      :event_date => event.datetime,
      :reservation_code => reservation.code
    }

    new()
    |> to({reservation.name, reservation.contact})
    |> from({"Südtiroler Volksbühne Kartenreservierung", "kartenreservierung@suedtiroler-volksbuehne.de"})
    |> subject("Reservierung erfolgreich - Reservierungsnummer #{reservation.code}")
    |> render_body("confirmation_mail.html", mail_params)
  end
end
