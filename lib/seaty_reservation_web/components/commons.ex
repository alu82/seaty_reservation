defmodule SeatyReservationWeb.Commons do
  def format_events_datetime(events) do
    events
    |> Enum.map(fn {dt, id}-> {format_datetime(dt), id} end)
  end

  def format_datetime(dt) do
    Calendar.strftime(dt, "%d.%m.%Y %H:%M")
  end
end
