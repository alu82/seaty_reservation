defmodule SeatyReservation.Allocations.Allocation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "allocations" do
    field :result, :map
    belongs_to :event, SeatyReservation.Events.Event

    timestamps()
  end

  def changeset(allocation, attrs) do
    allocation
    |> cast(attrs, [:result, :event_id])
    |> validate_required([:result, :event_id])
  end
end
