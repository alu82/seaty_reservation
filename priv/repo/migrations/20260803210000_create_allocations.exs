defmodule SeatyReservation.Repo.Migrations.CreateAllocations do
  use Ecto.Migration

  def change do
    create table(:allocations) do
      add :result, :map
      add :event_id, references(:events, on_delete: :delete_all)

      timestamps()
    end

    create index(:allocations, [:event_id])
  end
end
