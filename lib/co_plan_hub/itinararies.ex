defmodule CoPlanHub.Itineraries do
  @moduledoc """
  The Itineraries context.
  """

  import Ecto.Query, warn: false
  alias CoPlanHub.Repo

  alias CoPlanHub.Itineraries.Itinerary

  @doc """
  Returns the list of itineraries.

  ## Examples

      iex> list_itineraries()
      [%Itinerary{}, ...]

  """
  def list_itineraries do
    Repo.all(Itinerary)
  end

  @doc """
  Gets list of itineraries by user id.

  """
  def get_itineraries_by_user(user_id) do
    Itinerary
    |> where(user_id: ^user_id)
    |> order_by(asc: :start_date) # Order by start_date in ascending order
    |> Repo.all()
  end

  @doc """
  Gets a single itinerary.

  Raises `Ecto.NoResultsError` if the Itinerary does not exist.

  ## Examples

      iex> get_itinerary!(123)
      %Itinerary{}

      iex> get_itinerary!(456)
      ** (Ecto.NoResultsError)

  """
  def get_itinerary!(id), do: Repo.get!(Itinerary, id)


  @doc """
  Gets a single itinerary by guid.

  Raises `Ecto.NoResultsError` if the Itinerary does not exist.


  """
  def get_itinerary_by_guid!(guid) do
    Repo.get_by!(Itinerary, guid: guid)
  end

  @doc """
  Creates a itinerary.

  ## Examples

      iex> create_itinerary(%{field: value})
      {:ok, %Itinerary{}}

      iex> create_itinerary(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_itinerary(attrs \\ %{}, user) do
    Ecto.build_assoc(user, :itinerary)
    |> Repo.preload(:user)
    |> Itinerary.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a itinerary.

  ## Examples

      iex> update_itinerary(itinerary, %{field: new_value})
      {:ok, %Itinerary{}}

      iex> update_itinerary(itinerary, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_itinerary(%Itinerary{} = itinerary, attrs) do
    itinerary
    |> Itinerary.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a itinerary.

  ## Examples

      iex> delete_itinerary(itinerary)
      {:ok, %Itinerary{}}

      iex> delete_itinerary(itinerary)
      {:error, %Ecto.Changeset{}}

  """
  def delete_itinerary(%Itinerary{} = itinerary) do
    Repo.delete(itinerary)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking itinerary changes.

  ## Examples

      iex> change_itinerary(itinerary)
      %Ecto.Changeset{data: %Itinerary{}}

  """
  def change_itinerary(%Itinerary{} = itinerary, attrs \\ %{}) do
    Itinerary.changeset(itinerary, attrs)
  end
end
