defmodule SeatyReservation.Productions.Production do
  use Ecto.Schema
  import Ecto.Changeset

  schema "productions" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(production, attrs) do
    production
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
