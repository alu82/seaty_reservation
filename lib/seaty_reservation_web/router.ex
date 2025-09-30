defmodule SeatyReservationWeb.Router do
  use SeatyReservationWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :fetch_query_params
    plug :put_root_layout, html: {SeatyReservationWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug :basic_auth,
      username: Application.compile_env(:seaty_reservation, :basic_auth)[:username],
      password: Application.compile_env(:seaty_reservation, :basic_auth)[:password]
  end

  scope "/", SeatyReservationWeb do
    pipe_through [:browser]

    get "/", ReservationController , :new
    get "/reservations/new", ReservationController, :new
    get "/reservations/:id", ReservationController, :show
    post "/reservations", ReservationController, :create
  end

  scope "/", SeatyReservationWeb do
    pipe_through [:browser, :auth]

    resources "/events", EventController
    get "/reservations", ReservationController, :index
    get "/reservations_csv", ReservationController, :index_csv
    get "/reservations/:id/edit", ReservationController, :edit
    patch "/reservations/:id", ReservationController, :update
    put "/reservations/:id", ReservationController, :update
    patch "/reservations/:id/cancel", ReservationController, :cancel
    delete "/reservations/:id", ReservationController, :delete
    get "/events/:event_id/allocations/:id", AllocationController, :show
    post "/events/:event_id/allocations", AllocationController, :create
  end

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
