defmodule SeatyReservationWeb.EventHTML do
  use SeatyReservationWeb, :html
  import SeatyReservationWeb.Commons

  embed_templates "event_html/*"

  @doc """
  Renders a event form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def event_form(assigns)

  def get_reservation_count(event_id, reservations) do
    case Enum.find(reservations, fn {id, _res} -> id == event_id end) do
      {_id, res} -> res
      nil -> 0
    end
  end
end
