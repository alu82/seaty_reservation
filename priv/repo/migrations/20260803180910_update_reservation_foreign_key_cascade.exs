defmodule SeatyReservation.Repo.Migrations.UpdateReservationForeignKeyCascade do
  use Ecto.Migration

  def change do
    # Recreate reservations table with cascading delete
    # Note: This will delete all existing reservations
    execute "DELETE FROM reservations", "SELECT 1"
    drop table(:reservations)

    create table(:reservations) do
      add :prio, :integer
      add :code, :string
      add :name, :string
      add :seats, :integer
      add :contact, :string
      add :group, :integer
      add :preferred_row, :string
      add :comment, :text
      add :internal_comment, :string, default: ""
      add :event_id, references(:events, on_delete: :delete_all)
      add :token, :string

      timestamps()
    end

    create index(:reservations, [:event_id])
    create unique_index(:reservations, [:code])
  end
end
