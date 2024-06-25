defmodule CoPlanHub.Itinararies do
  @moduledoc """
  The Itinararies context.
  """

  import Ecto.Query, warn: false
  alias CoPlanHub.Repo

  alias CoPlanHub.Itinararies.Itinarary

  @doc """
  Returns the list of itinararies.

  ## Examples

      iex> list_itinararies()
      [%Itinarary{}, ...]

  """
  def list_itinararies do
    Repo.all(Itinarary)
  end

  @doc """
  Gets a single itinarary.

  Raises `Ecto.NoResultsError` if the Itinarary does not exist.

  ## Examples

      iex> get_itinarary!(123)
      %Itinarary{}

      iex> get_itinarary!(456)
      ** (Ecto.NoResultsError)

  """
  def get_itinarary!(id), do: Repo.get!(Itinarary, id)

  @doc """
  Creates a itinarary.

  ## Examples

      iex> create_itinarary(%{field: value})
      {:ok, %Itinarary{}}

      iex> create_itinarary(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_itinarary(attrs \\ %{}, user) do
    Ecto.build_assoc(user, :itinarary)
    |> Repo.preload(:user)
    |> Itinarary.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a itinarary.

  ## Examples

      iex> update_itinarary(itinarary, %{field: new_value})
      {:ok, %Itinarary{}}

      iex> update_itinarary(itinarary, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_itinarary(%Itinarary{} = itinarary, attrs) do
    itinarary
    |> Itinarary.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a itinarary.

  ## Examples

      iex> delete_itinarary(itinarary)
      {:ok, %Itinarary{}}

      iex> delete_itinarary(itinarary)
      {:error, %Ecto.Changeset{}}

  """
  def delete_itinarary(%Itinarary{} = itinarary) do
    Repo.delete(itinarary)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking itinarary changes.

  ## Examples

      iex> change_itinarary(itinarary)
      %Ecto.Changeset{data: %Itinarary{}}

  """
  def change_itinarary(%Itinarary{} = itinarary, attrs \\ %{}) do
    Itinarary.changeset(itinarary, attrs)
  end
end
