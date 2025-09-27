defmodule SeatyReservationWeb.Commons do
  import SeatyReservationWeb.Gettext

  def format_events(events) do
    Enum.map(
      events,
      fn {dt, seats, _active, id} ->
        display_text = ~s{#{format_datetime(dt)} (#{seats} #{gettext("Plätze verfügbar")})}
        {display_text, id}
      end
    )
  end

  def format_datetime(dt) do
    Calendar.strftime(dt, "%d.%m.%Y %H:%M")
  end

  def filter_active_events(events) do
    events
    |> Enum.filter(fn {_dt, _seats, active, _id} -> active end)
    |> Enum.map(fn {_dt, _seats, _active, id} -> id end)
  end
end
