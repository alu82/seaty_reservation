# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SeatyReservation.Repo.insert!(%SeatyReservation.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias SeatyReservation.Events

# Create default events
IO.puts("Creating default events...")

# Event dates and times
event_dates = [
  {~N[2025-11-21 20:00:00], "21.11.2025 um 20:00 Uhr"},
  {~N[2025-11-22 20:00:00], "22.11.2025 um 20:00 Uhr"},
  {~N[2025-11-23 16:00:00], "23.11.2025 um 16:00 Uhr"},
  {~N[2025-11-26 20:00:00], "26.11.2025 um 20:00 Uhr"},
  {~N[2025-11-27 20:00:00], "27.11.2025 um 20:00 Uhr"},
  {~N[2025-11-28 20:00:00], "28.11.2025 um 20:00 Uhr"}
]

# Create events in a loop
Enum.map(event_dates, fn {datetime, description} ->
  case Events.create_event(%{
    datetime: datetime,
    total_seats: 191,
    active: true
  }) do
    {:ok, event} ->
      IO.puts("✓ Created event: #{description}")
      event
    {:error, changeset} ->
      IO.puts("✗ Failed to create event #{description}: #{inspect(changeset.errors)}")
      nil
  end
end)

IO.puts("Seeding completed!")
