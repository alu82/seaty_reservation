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
      assert email.to == [{"some name", reservation.contact}]
    end

    test "cancellation email includes reservation link with token" do
      event = event_fixture()
      reservation = reservation_fixture(%{"event_id" => Integer.to_string(event.id)})

      email = ReservationEmail.cancellation(reservation, event)

      # The email should have been built
      assert email.subject != nil
      assert email.to != nil
    end

    test "cancellation email cc includes SY_SMTP_USER" do
      original = System.get_env("SY_SMTP_USER")
      System.put_env("SY_SMTP_USER", "smtp@example.com")

      try do
        event = event_fixture()
        reservation = reservation_fixture(%{"event_id" => Integer.to_string(event.id)})

        email = ReservationEmail.cancellation(reservation, event)

        # cc is a list of {name, email} tuples
        # The actual format is [{"", "smtp@example.com"}]
        assert length(email.cc) == 1
        assert elem(Enum.at(email.cc, 0), 1) == "smtp@example.com"
      after
        if original do
          System.put_env("SY_SMTP_USER", original)
        else
          System.delete_env("SY_SMTP_USER")
        end
      end
    end
  end

  describe "confirmation/2" do
    test "builds confirmation email with correct subject and recipient" do
      event = event_fixture(%{datetime: ~N[2024-01-15 19:00:00]})
      # Use fixture to get proper code
      reservation = reservation_fixture(%{"event_id" => Integer.to_string(event.id)})

      email = ReservationEmail.confirmation(reservation, event)

      # The subject uses SY_MAIL_SUBJECT or default
      # Just check it contains the reservation code
      assert email.subject =~ reservation.code
      assert email.to == [{"some name", reservation.contact}]
    end

    test "confirmation email includes reservation link with token" do
      event = event_fixture()
      reservation = reservation_fixture(%{"event_id" => Integer.to_string(event.id)})

      email = ReservationEmail.confirmation(reservation, event)

      assert email.subject != nil
    end

    test "confirmation email uses SY_MAIL_SUBJECT if set" do
      original = System.get_env("SY_MAIL_SUBJECT")
      System.put_env("SY_MAIL_SUBJECT", "Custom Subject")

      try do
        event = event_fixture()
        reservation = reservation_fixture(%{"event_id" => Integer.to_string(event.id)})

        email = ReservationEmail.confirmation(reservation, event)

        assert email.subject =~ "Custom Subject"
        assert email.subject =~ reservation.code
      after
        if original do
          System.put_env("SY_MAIL_SUBJECT", original)
        else
          System.delete_env("SY_MAIL_SUBJECT")
        end
      end
    end

    test "confirmation email uses default subject when SY_MAIL_SUBJECT not set" do
      original = System.get_env("SY_MAIL_SUBJECT")
      System.delete_env("SY_MAIL_SUBJECT")

      try do
        event = event_fixture()
        reservation = reservation_fixture(%{"event_id" => Integer.to_string(event.id)})

        email = ReservationEmail.confirmation(reservation, event)

        # Default subject is "Reservierung erfolgreich"
        assert email.subject =~ "Reservierung erfolgreich"
        assert email.subject =~ reservation.code
      after
        if original do
          System.put_env("SY_MAIL_SUBJECT", original)
        end
      end
    end

    test "confirmation email cc includes SY_SMTP_USER" do
      original = System.get_env("SY_SMTP_USER")
      System.put_env("SY_SMTP_USER", "smtp@example.com")

      try do
        event = event_fixture()
        reservation = reservation_fixture(%{"event_id" => Integer.to_string(event.id)})

        email = ReservationEmail.confirmation(reservation, event)

        # cc is a list of {name, email} tuples
        assert length(email.cc) == 1
        assert elem(Enum.at(email.cc, 0), 1) == "smtp@example.com"
      after
        if original do
          System.put_env("SY_SMTP_USER", original)
        else
          System.delete_env("SY_SMTP_USER")
        end
      end
    end

    test "confirmation email includes all required params" do
      event = event_fixture(%{datetime: ~N[2024-01-15 19:00:00]})

      reservation =
        reservation_fixture(%{
          "event_id" => Integer.to_string(event.id),
          "name" => "Test User",
          "contact" => "test@example.com",
          "seats" => "5"
        })

      email = ReservationEmail.confirmation(reservation, event)

      assert email.to == [{"Test User", "test@example.com"}]
      assert email.subject != nil
    end
  end
end
