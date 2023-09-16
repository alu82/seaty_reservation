defmodule SeatyReservationWeb.ReservationHTML do
  use SeatyReservationWeb, :html
  import SeatyReservationWeb.Commons

  embed_templates "reservation_html/*"

  @doc """
  Renders a simple reservation form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :events, :list, default: []
  attr :action, :string, required: true

  def reservation_form(assigns)

  @doc """
  Renders a full reservation form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :events, :list, default: []
  attr :action, :string, required: true

  def reservation_form_full(assigns)
end
