defmodule SeatyReservation.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :active, :boolean, default: false
    field :datetime, :naive_datetime
    field :seats, :integer
    has_many :reservations, SeatyReservation.Reservations.Reservation

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:datetime, :seats, :active])
    |> validate_required([:datetime, :seats, :active])
  end
end
