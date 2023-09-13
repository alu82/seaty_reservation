defmodule SeatyReservationWeb.Router do
  use SeatyReservationWeb, :router

  pipeline :browser do
    plug :basic_auth,
      username: Application.compile_env(:seaty_reservation, :basic_auth)[:username],
      password: Application.compile_env(:seaty_reservation, :basic_auth)[:password]
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SeatyReservationWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SeatyReservationWeb do
    pipe_through :browser

    get "/", ReservationController , :new
    resources "/reservations", ReservationController
    resources "/events", EventController
  end

  # Other scopes may use custom stacks.
  # scope "/api", SeatyReservationWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:seaty_reservation, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SeatyReservationWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
