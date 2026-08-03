defmodule SeatyReservation.ProductionsTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Productions
  alias SeatyReservation.Productions.Production

  describe "productions" do
    import SeatyReservation.ProductionsFixtures

    @invalid_attrs %{name: nil}

    test "list_productions/0 returns all productions" do
      production = production_fixture()
      assert Productions.list_productions() == [production]
    end

    test "get_production!/1 returns the production with given id" do
      production = production_fixture()
      assert Productions.get_production!(production.id) == production
    end

    test "create_production/1 with valid data creates a production" do
      valid_attrs = %{name: "Test Production"}
      assert {:ok, %Production{} = production} = Productions.create_production(valid_attrs)
      assert production.name == "Test Production"
    end

    test "create_production/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Productions.create_production(@invalid_attrs)
    end

    test "update_production/2 with valid data updates the production" do
      production = production_fixture()
      update_attrs = %{name: "Updated Production"}

      assert {:ok, %Production{} = production} =
               Productions.update_production(production, update_attrs)

      assert production.name == "Updated Production"
    end

    test "update_production/2 with invalid data returns error changeset" do
      production = production_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Productions.update_production(production, @invalid_attrs)

      assert production == Productions.get_production!(production.id)
    end

    test "delete_production/1 deletes the production" do
      production = production_fixture()
      assert {:ok, %Production{}} = Productions.delete_production(production)
      assert_raise Ecto.NoResultsError, fn -> Productions.get_production!(production.id) end
    end

    test "change_production/1 returns a production changeset" do
      production = production_fixture()
      assert %Ecto.Changeset{} = Productions.change_production(production)
    end
  end
end
