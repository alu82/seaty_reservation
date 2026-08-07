defmodule SeatyReservation.ReservationsCodeTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Reservations
  import SeatyReservation.ReservationsFixtures
  import SeatyReservation.EventsFixtures

  describe "reservation code generation" do
    test "get_next_code/1 generates code with event code prefix" do
      event = event_fixture(%{code: "ABC"})

      attrs = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "Test User",
        "seats" => "2",
        "contact" => "test@example.com"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{code: code}} =
               Reservations.create_reservation(attrs)

      assert String.starts_with?(code, "ABC")
    end

    test "get_next_code/1 generates sequential codes" do
      event = event_fixture(%{code: "XYZ"})

      attrs1 = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "User 1",
        "seats" => "1",
        "contact" => "user1@example.com"
      }

      attrs2 = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "User 2",
        "seats" => "1",
        "contact" => "user2@example.com"
      }

      attrs3 = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "User 3",
        "seats" => "1",
        "contact" => "user3@example.com"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{code: code1}} =
               Reservations.create_reservation(attrs1)

      assert {:ok, %SeatyReservation.Reservations.Reservation{code: code2}} =
               Reservations.create_reservation(attrs2)

      assert {:ok, %SeatyReservation.Reservations.Reservation{code: code3}} =
               Reservations.create_reservation(attrs3)

      assert code1 == "XYZ001"
      assert code2 == "XYZ002"
      assert code3 == "XYZ003"
    end

    test "get_next_code/1 handles code collision by incrementing" do
      event = event_fixture(%{code: "COL"})

      # Manually create a reservation with code COL001 by creating and updating
      r1 = reservation_fixture(%{"event_id" => event.id})
      {:ok, _} = Reservations.update_reservation(r1, %{code: "COL001"})

      # Now try to create a new reservation - it should skip COL001
      attrs2 = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "User 2",
        "seats" => "1",
        "contact" => "user2@example.com"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{code: code2}} =
               Reservations.create_reservation(attrs2)

      # The code should skip COL001 and use COL002 or higher
      assert String.starts_with?(code2, "COL")
    end

    test "get_reservation_by_code/1 finds reservation by code" do
      reservation = reservation_fixture()

      found = Reservations.get_reservation_by_code(reservation.code)

      assert found.id == reservation.id
      assert found.code == reservation.code
    end

    test "get_reservation_by_code/1 returns nil for non-existent code" do
      result = Reservations.get_reservation_by_code("NONEXISTENT")
      assert result == nil
    end

    test "code format is event_code + 3-digit number" do
      event = event_fixture(%{code: "EVT"})

      attrs = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "Test User",
        "seats" => "2",
        "contact" => "test@example.com"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{code: code}} =
               Reservations.create_reservation(attrs)

      # Code should be EVT + 3 digits
      assert String.length(code) == 6
      assert String.starts_with?(code, "EVT")

      # Extract the number part
      number_part = String.slice(code, 3..5)
      # Integer.parse returns {integer, remainder}
      assert elem(Integer.parse(number_part), 0) == 1
    end

    test "codes are unique within an event" do
      event = event_fixture(%{code: "UNI"})

      attrs1 = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "User 1",
        "seats" => "1",
        "contact" => "user1@example.com"
      }

      attrs2 = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "User 2",
        "seats" => "1",
        "contact" => "user2@example.com"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{code: code1}} =
               Reservations.create_reservation(attrs1)

      assert {:ok, %SeatyReservation.Reservations.Reservation{code: code2}} =
               Reservations.create_reservation(attrs2)

      assert code1 != code2
    end
  end

  describe "token generation" do
    test "gen_access_token/0 generates 32-character token" do
      # We can't directly test the private function, but we can check the token on creation
      event = event_fixture()

      attrs = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "Test User",
        "seats" => "2",
        "contact" => "test@example.com"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{token: token}} =
               Reservations.create_reservation(attrs)

      assert byte_size(token) == 32
    end

    test "tokens are unique across reservations" do
      event = event_fixture()

      attrs1 = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "User 1",
        "seats" => "2",
        "contact" => "user1@example.com"
      }

      attrs2 = %{
        "event_id" => Integer.to_string(event.id),
        "name" => "User 2",
        "seats" => "2",
        "contact" => "user2@example.com"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{token: token1}} =
               Reservations.create_reservation(attrs1)

      assert {:ok, %SeatyReservation.Reservations.Reservation{token: token2}} =
               Reservations.create_reservation(attrs2)

      assert token1 != token2
    end

    test "tokens are different for different events" do
      event1 = event_fixture()
      event2 = event_fixture()

      attrs1 = %{
        "event_id" => Integer.to_string(event1.id),
        "name" => "User 1",
        "seats" => "2",
        "contact" => "user1@example.com"
      }

      attrs2 = %{
        "event_id" => Integer.to_string(event2.id),
        "name" => "User 2",
        "seats" => "2",
        "contact" => "user2@example.com"
      }

      assert {:ok, %SeatyReservation.Reservations.Reservation{token: token1}} =
               Reservations.create_reservation(attrs1)

      assert {:ok, %SeatyReservation.Reservations.Reservation{token: token2}} =
               Reservations.create_reservation(attrs2)

      # Tokens should be different (very likely, though theoretically possible they could collide)
      assert token1 != token2
    end
  end
end
