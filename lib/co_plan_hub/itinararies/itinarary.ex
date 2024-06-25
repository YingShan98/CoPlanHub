defmodule CoPlanHub.Itineraries.Itinerary do
  alias CoPlanHub.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  schema "itineraries" do
    field :name, :string
    field :description, :string
    field :start_date, :date
    field :end_date, :date
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(itinerary, attrs) do
    itinerary
    |> cast(attrs, [:name, :description, :start_date, :end_date])
    |> validate_required([:user_id, :name, :description, :start_date, :end_date])
  end
end
