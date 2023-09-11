defmodule SeatyReservation.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SeatyReservationWeb.Telemetry,
      # Start the Ecto repository
      SeatyReservation.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: SeatyReservation.PubSub},
      # Start Finch
      {Finch, name: SeatyReservation.Finch},
      # Start the Endpoint (http/https)
      SeatyReservationWeb.Endpoint
      # Start a worker by calling: SeatyReservation.Worker.start_link(arg)
      # {SeatyReservation.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SeatyReservation.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SeatyReservationWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
