defmodule SeatyReservation.Repo.Migrations.CreateReservations do
  use Ecto.Migration

  def change do
    create table(:reservations) do
      add :prio, :integer
      add :code, :string
      add :name, :string
      add :seats, :integer
      add :contact, :string
      add :group, :integer
      add :preferred_row, :string
      add :comment, :text
      add :event_id, references(:events, on_delete: :nothing)

      timestamps()
    end

    create index(:reservations, [:event_id])
    create unique_index(:reservations, [:code])
  end
end
