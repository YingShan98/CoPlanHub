defmodule CoPlanHub.Repo.Migrations.AddGuidToItineraries do
  use Ecto.Migration

  def change do
    alter table(:itineraries) do
      add :guid, :uuid, null: false
    end
  end
end
