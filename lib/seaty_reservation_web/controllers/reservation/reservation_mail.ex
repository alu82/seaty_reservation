defmodule SeatyReservation.ReservationEmail do
  use Phoenix.Swoosh,
    template_root: "lib/seaty_reservation_web/controllers/reservation/reservation_html",
    template_path: "mail"

  def confirmation() do
    new()
    |> to({"Alexander", "ldw_null@posteo.de"})
    |> from({"Kartenreservierung SVB", "kartenreservierung@suedtiroler-volksbuehne.de"})
    |> subject("Reservierung erfolgreich")
    |> render_body("confirmation_mail.html", %{name: "alexander"})
  end
end
