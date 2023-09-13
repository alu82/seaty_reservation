# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :seaty_reservation,
  ecto_repos: [SeatyReservation.Repo]

# Configures the endpoint
config :seaty_reservation, SeatyReservationWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: SeatyReservationWeb.ErrorHTML, json: SeatyReservationWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: SeatyReservation.PubSub,
  live_view: [signing_salt: "CQ/enHH6"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :seaty_reservation, SeatyReservation.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# set the locales
config :seaty_reservation, SeatyReservationWeb.Gettext, locales: ~w(de en)

# basic auth setup
config :seaty_reservation, :basic_auth,
  username: System.get_env("SY_BASIC_AUTH_USER") || "seaty",
  password: System.get_env("SY_BASIC_AUTH_PASSWORD") || "password"

config :seaty_reservation, SeatyReservation.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: "smtp.ionos.de",
  port: 587,
  username: System.get_env("SY_SMTP_USER"),
  password: System.get_env("SY_SMTP_PASSWORD"),
  ssl: :false,
  tls: :if_available,
  auth: :always,
  tls_options: [
    verify: :verify_none
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
