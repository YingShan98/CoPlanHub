defmodule CoPlanHub.ItinerariesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CoPlanHub.Itineraries` context.
  """

  @doc """
  Generate a itinarary.
  """
  def itinarary_fixture(attrs \\ %{}) do
    {:ok, itinarary} =
      attrs
      |> Enum.into(%{
        description: "some description",
        end_date: ~D[2024-06-24],
        name: "some name",
        start_date: ~D[2024-06-24]
      })
      |> CoPlanHub.Itineraries.create_itinarary()

    itinarary
  end
end
