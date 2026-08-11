defmodule SeatyReservationWeb.Router do
  use SeatyReservationWeb, :router

  import SeatyReservationWeb.UserAuth

  alias SeatyReservation.Allocations.Allocation
  alias SeatyReservation.Events.Event
  alias SeatyReservation.Productions.Production
  alias SeatyReservation.Reservations.Reservation
  alias SeatyReservation.Users.User

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :fetch_query_params
    plug :put_root_layout, html: {SeatyReservationWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :authorized do
    plug :check_authorization
  end

  pipeline :authenticated do
    plug :require_authenticated_user
  end

  scope "/", SeatyReservationWeb do
    pipe_through [:browser, :authorized]

    get "/", ReservationController, :new,
      private: %{authorization: {:create, Reservation}}

    get "/reservations/new", ReservationController, :new,
      private: %{authorization: {:create, Reservation}}

    get "/reservations/:id", ReservationController, :show,
      private: %{authorization: {:show, Reservation}}

    post "/reservations", ReservationController, :create,
      private: %{authorization: {:create, Reservation}}
  end

  scope "/", SeatyReservationWeb do
    pipe_through [:browser, :authenticated]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", SeatyReservationWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", SeatyReservationWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end

  scope "/", SeatyReservationWeb do
    pipe_through [:browser, :authenticated, :authorized]

    # Events
    get "/events", EventController, :index,
      private: %{authorization: {:index, Event}}

    get "/events/new", EventController, :new,
      private: %{authorization: {:create, Event}}

    post "/events", EventController, :create,
      private: %{authorization: {:create, Event}}

    get "/events/:id", EventController, :show,
      private: %{authorization: {:show, Event}}

    get "/events/:id/edit", EventController, :edit,
      private: %{authorization: {:update, Event}}

    patch "/events/:id", EventController, :update,
      private: %{authorization: {:update, Event}}

    put "/events/:id", EventController, :update,
      private: %{authorization: {:update, Event}}

    delete "/events/:id", EventController, :delete,
      private: %{authorization: {:delete, Event}}

    # Productions
    get "/productions", ProductionController, :index,
      private: %{authorization: {:index, Production}}

    get "/productions/new", ProductionController, :new,
      private: %{authorization: {:create, Production}}

    post "/productions", ProductionController, :create,
      private: %{authorization: {:create, Production}}

    get "/productions/:id", ProductionController, :show,
      private: %{authorization: {:show, Production}}

    get "/productions/:id/edit", ProductionController, :edit,
      private: %{authorization: {:update, Production}}

    patch "/productions/:id", ProductionController, :update,
      private: %{authorization: {:update, Production}}

    put "/productions/:id", ProductionController, :update,
      private: %{authorization: {:update, Production}}

    delete "/productions/:id", ProductionController, :delete,
      private: %{authorization: {:delete, Production}}

    # Reservations
    get "/reservations", ReservationController, :index,
      private: %{authorization: {:index, Reservation}}

    get "/reservations_csv", ReservationController, :index_csv,
      private: %{authorization: {:index, Reservation}}

    get "/reservations/:id/edit", ReservationController, :edit,
      private: %{authorization: {:update, Reservation}}

    patch "/reservations/:id", ReservationController, :update,
      private: %{authorization: {:update, Reservation}}

    put "/reservations/:id", ReservationController, :update,
      private: %{authorization: {:update, Reservation}}

    patch "/reservations/:id/cancel", ReservationController, :cancel,
      private: %{authorization: {:update, Reservation}}

    delete "/reservations/:id", ReservationController, :delete,
      private: %{authorization: {:delete, Reservation}}

    # Allocations
    post "/events/:event_id/allocations", AllocationController, :create,
      private: %{authorization: {:create, Allocation}}

    get "/events/:event_id/allocations/:id", AllocationController, :show,
      private: %{authorization: {:show, Allocation}}

    delete "/events/:event_id/allocations/:id", AllocationController, :delete,
      private: %{authorization: {:delete, Allocation}}

    # Users
    get "/users", UserController, :index,
      private: %{authorization: {:index, User}}

    get "/users/new", UserController, :new,
      private: %{authorization: {:create, User}}

    post "/users", UserController, :create,
      private: %{authorization: {:create, User}}

    get "/users/:id", UserController, :show,
      private: %{authorization: {:show, User}}

    get "/users/:id/edit", UserController, :edit,
      private: %{authorization: {:update, User}}

    patch "/users/:id", UserController, :update,
      private: %{authorization: {:update, User}}

    put "/users/:id", UserController, :update,
      private: %{authorization: {:update, User}}

    delete "/users/:id", UserController, :delete,
      private: %{authorization: {:delete, User}}
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
