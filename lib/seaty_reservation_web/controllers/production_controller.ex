defmodule SeatyReservationWeb.ProductionController do
  use SeatyReservationWeb, :controller

  alias SeatyReservation.Productions
  alias SeatyReservation.Productions.Production

  def index(conn, _params) do
    productions = Productions.list_productions()
    render(conn, :index, productions: productions)
  end

  def new(conn, _params) do
    changeset = Productions.change_production(%Production{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"production" => production_params}) do
    case Productions.create_production(production_params) do
      {:ok, production} ->
        conn
        |> put_flash(:info, "Production created successfully.")
        |> redirect(to: ~p"/productions/#{production}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    production = Productions.get_production!(id)
    render(conn, :show, production: production)
  end

  def edit(conn, %{"id" => id}) do
    production = Productions.get_production!(id)
    changeset = Productions.change_production(production)
    render(conn, :edit, production: production, changeset: changeset)
  end

  def update(conn, %{"id" => id, "production" => production_params}) do
    production = Productions.get_production!(id)

    case Productions.update_production(production, production_params) do
      {:ok, production} ->
        conn
        |> put_flash(:info, "Production updated successfully.")
        |> redirect(to: ~p"/productions/#{production}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, production: production, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    production = Productions.get_production!(id)
    {:ok, _production} = Productions.delete_production(production)

    conn
    |> put_flash(:info, "Production deleted successfully.")
    |> redirect(to: ~p"/productions")
  end
end
