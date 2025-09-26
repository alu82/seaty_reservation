defmodule SeatyReservation.Repo.Migrations.AddInternalCommentToReservations do
  use Ecto.Migration

  def change do
    alter table(:reservations) do
      add :internal_comment, :text
    end
  end
end
