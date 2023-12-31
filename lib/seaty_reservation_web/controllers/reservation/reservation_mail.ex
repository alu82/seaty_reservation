defmodule SeatyReservation.ReservationEmail do
  use Phoenix.Swoosh,
    template_root: "lib/seaty_reservation_web/controllers/reservation/reservation_html",
    template_path: "mail"

  import SeatyReservationWeb.Commons

  def confirmation(reservation, event) do
    reservation_link = "#{SeatyReservationWeb.Endpoint.url()}/reservations/#{reservation.id}?token=#{URI.encode_www_form(reservation.token)}"
    mail_params = %{
      :name => reservation.name,
      :seats => reservation.seats,
      :event_date => event.datetime,
      :reservation_code => reservation.code,
      :reservation_link => reservation_link
    }

    subject = System.get_env("SY_MAIL_SUBJECT") || "Reservierung erfolgreich"

    new()
    |> to({reservation.name, reservation.contact})
    |> cc(System.get_env("SY_SMTP_USER"))
    |> from({"Südtiroler Volksbühne Kartenreservierung", System.get_env("SY_SMTP_USER")})
    |> subject("#{subject} - Reservierungsnummer #{reservation.code}")
    |> render_body("confirmation_mail.html", mail_params)
  end
end
