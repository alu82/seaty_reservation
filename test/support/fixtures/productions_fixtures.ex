defmodule SeatyReservation.ProductionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SeatyReservation.Productions` context.
  """

  @doc """
  Generate a production.
  """
  def production_fixture do
    attrs = %{name: "Test Production"}
    {:ok, production} = SeatyReservation.Productions.create_production(attrs)
    production
  end
end
