defmodule SeatyReservationWeb.Commons do
  def format_events_datetime(events) do
    events
    |> Enum.map(fn {dt, id}-> {Calendar.strftime(dt, "%a %d.%m.%Y %H:%M"), id} end)
  end
end
