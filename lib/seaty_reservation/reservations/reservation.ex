defmodule SeatyReservation.Reservations.Reservation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reservations" do
    field :code, :string
    field :name, :string
    field :group, :integer
    field :comment, :string
    field :prio, :integer
    field :order_date, :naive_datetime
    field :contact, :string
    field :preferred_row, :string
    belongs_to :event, SeatyReservation.Events.Event

    timestamps()
  end

  @doc false
  def changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [:prio, :order_date, :code, :name, :contact, :group, :preferred_row, :comment])
    |> validate_required([:prio, :order_date, :code, :name, :contact, :group, :preferred_row, :comment])
  end
end
