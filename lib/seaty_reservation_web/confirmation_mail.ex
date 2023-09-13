defmodule SeatyReservation.ConfirmationEmail do
  import Swoosh.Email

  def welcome() do
    new()
    |> to({"Alexander", "test@test.de"})
    |> from({"Kartenreservierung SVB", "test@test.de"})
    |> subject("Reservierung erfolgreich")
    |> html_body("<h1>Hello from Phoenix</h1>")
    |> text_body("Hello from Phoenix\n")
  end
end
