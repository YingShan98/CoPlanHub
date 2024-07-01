defmodule CoPlanHub.Attachments.Image do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.UUID

  schema "images" do
    field :filename, :string
    field :description, :string
    field :bytes, :binary
    field :guid, Ecto.UUID, autogenerate: true, default: UUID.generate()

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:guid, :filename, :description, :bytes])
    |> validate_required([:guid, :filename, :description, :bytes])
  end
end
