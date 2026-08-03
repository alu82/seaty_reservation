defmodule SeatyReservation.ReservationEmailTest do
  use SeatyReservation.DataCase

  import SeatyReservation.ReservationsFixtures
  import SeatyReservation.EventsFixtures

  alias SeatyReservation.ReservationEmail

  describe "cancellation/2" do
    test "builds cancellation email with correct subject and recipient" do
      event = event_fixture()
      reservation = reservation_fixture(%{"event_id" => Integer.to_string(event.id)})

      email = ReservationEmail.cancellation(reservation, event)

      assert email.subject =~ "Reservierung storniert"
      assert email.subject =~ to_string(reservation.code)
      assert email.to == [{reservation.name, reservation.contact}]
    end
  end
end
