defmodule SeatyReservation.Reservations.Reservation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reservations" do
    field :code, :string
    field :name, :string
    field :seats, :integer
    field :group, :integer
    field :comment, :string
    field :internal_comment, :string, default: ""
    field :prio, :integer
    field :contact, :string
    field :preferred_row, :string
    field :token, :string
    belongs_to :event, SeatyReservation.Events.Event

    timestamps()
  end

  @doc false
  def changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [:prio, :code, :name, :contact, :group, :preferred_row, :comment, :internal_comment, :event_id, :seats, :token])
    |> validate_required([:prio, :code, :name, :contact, :event_id, :seats])
  end
end
