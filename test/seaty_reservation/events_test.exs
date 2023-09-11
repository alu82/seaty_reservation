defmodule SeatyReservation.EventsTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Events

  describe "events" do
    alias SeatyReservation.Events.Event

    import SeatyReservation.EventsFixtures

    @invalid_attrs %{active: nil, datetime: nil, seats: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{active: true, datetime: ~N[2023-09-10 21:17:00], seats: 42}

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
      assert event.active == true
      assert event.datetime == ~N[2023-09-10 21:17:00]
      assert event.seats == 42
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      update_attrs = %{active: false, datetime: ~N[2023-09-11 21:17:00], seats: 43}

      assert {:ok, %Event{} = event} = Events.update_event(event, update_attrs)
      assert event.active == false
      assert event.datetime == ~N[2023-09-11 21:17:00]
      assert event.seats == 43
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end
end
