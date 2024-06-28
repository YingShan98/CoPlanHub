defmodule CoPlanHub.Repo.Migrations.AddLocationToItinerary do
  use Ecto.Migration

  def change do
    alter table(:itineraries) do
      add :location, :string
      add :budget, :decimal
    end
  end
end
