defmodule SeatyReservation.Repo.Migrations.CreateReservations do
  use Ecto.Migration

  def change do
    create table(:reservations) do
      add :prio, :integer
      add :order_date, :naive_datetime
      add :code, :string
      add :name, :string
      add :contact, :string
      add :group, :integer
      add :preferred_row, :string
      add :comment, :text
      add :event_id, references(:events, on_delete: :nothing)

      timestamps()
    end

    create index(:reservations, [:event_id])
  end
end
