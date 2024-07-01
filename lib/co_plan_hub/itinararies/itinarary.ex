defmodule CoPlanHub.Itineraries.Itinerary do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.UUID
  alias CoPlanHub.Accounts.User
  alias CoPlanHub.Attachments.Image

  schema "itineraries" do
    field :guid, Ecto.UUID, autogenerate: true, default: UUID.generate()
    field :name, :string
    field :description, :string
    field :start_date, :date
    field :end_date, :date
    field :location, :string
    field :budget, :decimal
    belongs_to :user, User
    belongs_to :image, Image

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(itinerary, attrs) do
    itinerary
    |> cast(attrs, [:guid, :name, :description, :start_date, :end_date, :location, :budget])
    |> cast_assoc(:image)
    |> validate_required([:user_id, :name, :description, :start_date, :location])
    |> assoc_constraint(:image)
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
