defmodule SeatyReservation.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :datetime, :naive_datetime
      add :total_seats, :integer
      add :active, :boolean, default: false, null: false

      timestamps()
    end
  end
end
