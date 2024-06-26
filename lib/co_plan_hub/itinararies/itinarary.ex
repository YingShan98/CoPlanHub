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
    |> validate_required([:user_id, :name, :description, :start_date])
    |> validate_date_range()
  end

  defp validate_date_range(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    if start_date && end_date && Date.compare(start_date, end_date) == :gt do
      add_error(changeset, :end_date, "End date must be after start date")
    else
      changeset
    end
  end
end
