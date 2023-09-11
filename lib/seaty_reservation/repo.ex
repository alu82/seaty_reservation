defmodule SeatyReservation.Repo do
  use Ecto.Repo,
    otp_app: :seaty_reservation,
    adapter: Ecto.Adapters.SQLite3
end
