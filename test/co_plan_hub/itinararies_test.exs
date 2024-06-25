defmodule CoPlanHub.ItinerariesTest do
  use CoPlanHub.DataCase

  alias CoPlanHub.Itineraries

  describe "itineraries" do
    alias CoPlanHub.Itineraries.Itinarary

    import CoPlanHub.ItinerariesFixtures

    @invalid_attrs %{name: nil, description: nil, start_date: nil, end_date: nil}

    test "list_itineraries/0 returns all itineraries" do
      itinarary = itinarary_fixture()
      assert Itineraries.list_itineraries() == [itinarary]
    end

    test "get_itinarary!/1 returns the itinarary with given id" do
      itinarary = itinarary_fixture()
      assert Itineraries.get_itinarary!(itinarary.id) == itinarary
    end

    test "create_itinarary/1 with valid data creates a itinarary" do
      valid_attrs = %{name: "some name", description: "some description", start_date: ~D[2024-06-24], end_date: ~D[2024-06-24]}

      assert {:ok, %Itinarary{} = itinarary} = Itineraries.create_itinarary(valid_attrs)
      assert itinarary.name == "some name"
      assert itinarary.description == "some description"
      assert itinarary.start_date == ~D[2024-06-24]
      assert itinarary.end_date == ~D[2024-06-24]
    end

    test "create_itinarary/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Itineraries.create_itinarary(@invalid_attrs)
    end

    test "update_itinarary/2 with valid data updates the itinarary" do
      itinarary = itinarary_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", start_date: ~D[2024-06-25], end_date: ~D[2024-06-25]}

      assert {:ok, %Itinarary{} = itinarary} = Itineraries.update_itinarary(itinarary, update_attrs)
      assert itinarary.name == "some updated name"
      assert itinarary.description == "some updated description"
      assert itinarary.start_date == ~D[2024-06-25]
      assert itinarary.end_date == ~D[2024-06-25]
    end

    test "update_itinarary/2 with invalid data returns error changeset" do
      itinarary = itinarary_fixture()
      assert {:error, %Ecto.Changeset{}} = Itineraries.update_itinarary(itinarary, @invalid_attrs)
      assert itinarary == Itineraries.get_itinarary!(itinarary.id)
    end

    test "delete_itinarary/1 deletes the itinarary" do
      itinarary = itinarary_fixture()
      assert {:ok, %Itinarary{}} = Itineraries.delete_itinarary(itinarary)
      assert_raise Ecto.NoResultsError, fn -> Itineraries.get_itinarary!(itinarary.id) end
    end

    test "change_itinarary/1 returns a itinarary changeset" do
      itinarary = itinarary_fixture()
      assert %Ecto.Changeset{} = Itineraries.change_itinarary(itinarary)
    end
  end
end
