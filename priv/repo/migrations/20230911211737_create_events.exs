defmodule SeatyReservation.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :datetime, :naive_datetime
      add :seats, :integer
      add :active, :boolean, default: false, null: false

      timestamps()
    end
  end
end
