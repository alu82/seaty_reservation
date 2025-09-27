defmodule SeatyReservationWeb.Commons do
  import SeatyReservationWeb.Gettext

  def format_events(events) do
    Enum.map(
      events,
      fn {dt, seats, id} ->
        display_text = ~s{#{format_datetime(dt)} (#{seats} #{gettext("Plätze verfügbar")})}
        {display_text, id}
      end
    )
  end

  def format_datetime(dt) do
    Calendar.strftime(dt, "%d.%m.%Y %H:%M")
  end
end
