defmodule SeatyReservation.Release do
  @app :seaty_reservation

  def migrate do
    load_app()

    for repo <- repos() do
      Ecto.Migrator.with_repo(repo, fn repo ->
        Ecto.Migrator.run(repo, :up, all: true)
      end)
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.ensure_all_started(@app)
  end
end
