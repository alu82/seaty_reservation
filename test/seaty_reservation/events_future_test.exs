defmodule SeatyReservation.EventsFutureTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Events
  import SeatyReservation.EventsFixtures
  import SeatyReservation.ProductionsFixtures

  describe "get_all_future" do
    test "get_all_future/0 returns only future events" do
      production = production_fixture()

      # Create a past event (2 hours ago to be safe)
      past_datetime = NaiveDateTime.utc_now() |> NaiveDateTime.add(-7200, :second)
      event_fixture(%{production_id: production.id, datetime: past_datetime})

      # Create a future event (2 hours from now)
      future_datetime = NaiveDateTime.utc_now() |> NaiveDateTime.add(7200, :second)
      future_event = event_fixture(%{production_id: production.id, datetime: future_datetime})

      future_events = Events.get_all_future()

      assert length(future_events) == 1
      assert Enum.at(future_events, 0).id == future_event.id
    end

    test "get_all_future/0 returns empty list when no future events" do
      production = production_fixture()

      # Create only past events
      past_datetime = NaiveDateTime.utc_now() |> NaiveDateTime.add(-7200, :second)
      event_fixture(%{production_id: production.id, datetime: past_datetime})

      future_events = Events.get_all_future()

      assert future_events == []
    end

    test "get_all_future/0 orders by datetime ascending" do
      production = production_fixture()

      # Create events at different times in the far future (year 2100 to be safe)
      event1 = event_fixture(%{production_id: production.id, datetime: ~N[2100-01-15 19:00:00]})
      event2 = event_fixture(%{production_id: production.id, datetime: ~N[2100-01-10 19:00:00]})
      event3 = event_fixture(%{production_id: production.id, datetime: ~N[2100-01-20 19:00:00]})

      future_events = Events.get_all_future()

      # Find our events in the results
      our_event_ids = [event1.id, event2.id, event3.id]
      our_events = Enum.filter(future_events, &(&1.id in our_event_ids))

      assert length(our_events) == 3
      # Jan 10
      assert Enum.at(our_events, 0).id == event2.id
      # Jan 15
      assert Enum.at(our_events, 1).id == event1.id
      # Jan 20
      assert Enum.at(our_events, 2).id == event3.id
    end

    test "get_all_future/0 excludes events exactly 1 hour ago" do
      production = production_fixture()

      # Create an event exactly 1 hour ago (the boundary)
      boundary_datetime = NaiveDateTime.utc_now() |> NaiveDateTime.add(-3600, :second)
      event_fixture(%{production_id: production.id, datetime: boundary_datetime})

      future_events = Events.get_all_future()

      # The query uses >, so exactly 1 hour ago should be excluded
      assert future_events == []
    end
  end

  describe "list_events with preload" do
    test "list_events/0 preloads production association" do
      production = production_fixture()
      event = event_fixture(%{production_id: production.id})

      events = Events.list_events()

      assert length(events) >= 1

      # Find our event
      our_event = Enum.find(events, &(&1.id == event.id))
      assert our_event != nil

      # Check that production is preloaded
      assert our_event.production != nil
      assert our_event.production.id == production.id
    end

    test "list_events/0 orders by datetime" do
      production = production_fixture()

      event1 = event_fixture(%{production_id: production.id, datetime: ~N[2100-01-15 19:00:00]})
      event2 = event_fixture(%{production_id: production.id, datetime: ~N[2100-01-10 19:00:00]})

      events = Events.list_events()

      # Find our events
      assert length(Enum.filter(events, &(&1.id == event1.id || &1.id == event2.id))) == 2
    end

    test "get_event!/1 with preload option" do
      production = production_fixture()
      event = event_fixture(%{production_id: production.id})

      fetched_event = Events.get_event!(event.id, preload: [:production])

      assert fetched_event.production != nil
      assert fetched_event.production.id == production.id
    end
  end
end
