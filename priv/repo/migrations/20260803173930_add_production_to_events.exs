defmodule SeatyReservation.Repo.Migrations.AddProductionToEvents do
  use Ecto.Migration

  def change do
    # Breaking change: delete all existing reservations and events
    # since production_id is now required
    execute "DELETE FROM reservations", "SELECT 1"
    execute "DELETE FROM events", "SELECT 1"

    alter table(:events) do
      add :production_id, references(:productions, on_delete: :delete_all), null: false
    end
  end
end
