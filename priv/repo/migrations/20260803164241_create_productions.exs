defmodule SeatyReservation.Repo.Migrations.CreateProductions do
  use Ecto.Migration

  def change do
    create table(:productions) do
      add :name, :string, null: false

      timestamps()
    end
  end
end
