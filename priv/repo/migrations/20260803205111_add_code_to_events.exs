defmodule SeatyReservation.Repo.Migrations.AddCodeToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :code, :string, default: ""
    end

    execute("UPDATE events SET code = CAST(id AS TEXT)")
  end
end
