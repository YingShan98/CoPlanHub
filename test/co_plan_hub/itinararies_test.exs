defmodule CoPlanHub.ItinarariesTest do
  use CoPlanHub.DataCase

  alias CoPlanHub.Itinararies

  describe "itinararies" do
    alias CoPlanHub.Itinararies.Itinarary

    import CoPlanHub.ItinarariesFixtures

    @invalid_attrs %{name: nil, description: nil, start_date: nil, end_date: nil}

    test "list_itinararies/0 returns all itinararies" do
      itinarary = itinarary_fixture()
      assert Itinararies.list_itinararies() == [itinarary]
    end

    test "get_itinarary!/1 returns the itinarary with given id" do
      itinarary = itinarary_fixture()
      assert Itinararies.get_itinarary!(itinarary.id) == itinarary
    end

    test "create_itinarary/1 with valid data creates a itinarary" do
      valid_attrs = %{name: "some name", description: "some description", start_date: ~D[2024-06-24], end_date: ~D[2024-06-24]}

      assert {:ok, %Itinarary{} = itinarary} = Itinararies.create_itinarary(valid_attrs)
      assert itinarary.name == "some name"
      assert itinarary.description == "some description"
      assert itinarary.start_date == ~D[2024-06-24]
      assert itinarary.end_date == ~D[2024-06-24]
    end

    test "create_itinarary/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Itinararies.create_itinarary(@invalid_attrs)
    end

    test "update_itinarary/2 with valid data updates the itinarary" do
      itinarary = itinarary_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", start_date: ~D[2024-06-25], end_date: ~D[2024-06-25]}

      assert {:ok, %Itinarary{} = itinarary} = Itinararies.update_itinarary(itinarary, update_attrs)
      assert itinarary.name == "some updated name"
      assert itinarary.description == "some updated description"
      assert itinarary.start_date == ~D[2024-06-25]
      assert itinarary.end_date == ~D[2024-06-25]
    end

    test "update_itinarary/2 with invalid data returns error changeset" do
      itinarary = itinarary_fixture()
      assert {:error, %Ecto.Changeset{}} = Itinararies.update_itinarary(itinarary, @invalid_attrs)
      assert itinarary == Itinararies.get_itinarary!(itinarary.id)
    end

    test "delete_itinarary/1 deletes the itinarary" do
      itinarary = itinarary_fixture()
      assert {:ok, %Itinarary{}} = Itinararies.delete_itinarary(itinarary)
      assert_raise Ecto.NoResultsError, fn -> Itinararies.get_itinarary!(itinarary.id) end
    end

    test "change_itinarary/1 returns a itinarary changeset" do
      itinarary = itinarary_fixture()
      assert %Ecto.Changeset{} = Itinararies.change_itinarary(itinarary)
    end
  end
end
