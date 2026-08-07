defmodule SeatyReservation.ReservationsPriorityTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Reservations
  import SeatyReservation.ReservationsFixtures
  import SeatyReservation.EventsFixtures

  describe "priority system" do
    test "get_next_prio/1 returns min_prio - 5 for first reservation" do
      event = event_fixture()

      # First reservation should get 1000 - 5 = 995 (since min(coalesce(1000)) - 5)
      attrs = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "First User",
        "seats" => "2",
        "contact" => "first@example.com"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{prio: 995}} =
               Reservations.create_reservation(attrs)
    end

    test "get_next_prio/1 returns min(existing_prio) - 5 for subsequent reservations" do
      event = event_fixture()

      # First reservation - will get 995
      reservation1 = reservation_fixture(%{"event_id" => event.id})
      # Update it to have prio 100
      {:ok, _} = Reservations.update_reservation(reservation1, %{prio: 100})

      # Second reservation should get 100 - 5 = 95
      attrs = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "Second User",
        "seats" => "2",
        "contact" => "second@example.com"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{prio: 95}} =
               Reservations.create_reservation(attrs)

      # Third reservation should get 95 - 5 = 90
      attrs3 = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "Third User",
        "seats" => "2",
        "contact" => "third@example.com"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{prio: 90}} =
               Reservations.create_reservation(attrs3)
    end

    test "cancelled reservations have prio = 0" do
      reservation = reservation_fixture()

      # Cancel the reservation
      {:ok, cancelled} =
        Reservations.update_reservation(reservation, %{
          seats: 0,
          internal_comment: "storniert",
          prio: 0
        })

      assert cancelled.prio == 0
      assert cancelled.seats == 0
      assert cancelled.internal_comment == "storniert"
    end

    test "cancelled reservations are excluded from priority calculation" do
      event = event_fixture()

      # Create a cancelled reservation (prio = 0, seats = 0)
      reservation1 = reservation_fixture(%{"event_id" => event.id})
      {:ok, _} = Reservations.update_reservation(reservation1, %{prio: 0, seats: 0})

      # Create an active reservation with prio 100
      reservation2 = reservation_fixture(%{"event_id" => event.id})
      {:ok, _} = Reservations.update_reservation(reservation2, %{prio: 100})

      # Next reservation should get 100 - 5 = 95 (ignoring the cancelled one)
      attrs = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "New User",
        "seats" => "2",
        "contact" => "new@example.com"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{prio: 95}} =
               Reservations.create_reservation(attrs)
    end

    test "get_next_prio/1 handles multiple existing priorities" do
      event = event_fixture()

      # Create reservations with different priorities
      r1 = reservation_fixture(%{"event_id" => event.id})
      r2 = reservation_fixture(%{"event_id" => event.id})

      {:ok, _} = Reservations.update_reservation(r1, %{prio: 200})
      {:ok, _} = Reservations.update_reservation(r2, %{prio: 150})

      # Next reservation should get min(200, 150) - 5 = 145
      attrs = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "New User",
        "seats" => "2",
        "contact" => "new@example.com"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{prio: 145}} =
               Reservations.create_reservation(attrs)
    end
  end
end
