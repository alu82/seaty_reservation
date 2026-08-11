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

  def create_first_admin([admin_email, admin_password]) do
    load_app()

    alias SeatyReservation.Users

    admin_exists? = Users.list_users() |> Enum.any?(fn user -> user.role == :admin end)

    if !admin_exists? do
      IO.puts("Creating admin user...")

      case Users.create_user(%{
        email: admin_email,
        password: admin_password,
        role: :admin
      }) do
        {:ok, _user} ->
          IO.puts("✓ Admin user created: #{admin_email}")

        {:error, changeset} ->
          IO.puts("✗ Failed to create admin user: #{inspect(changeset.errors)}")
          raise "Admin user creation failed"
      end
    else
      IO.puts("✓ Admin user already exists, skipping creation")
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.ensure_all_started(@app)
  end
end
