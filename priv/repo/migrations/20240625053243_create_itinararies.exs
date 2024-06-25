defmodule CoPlanHub.Repo.Migrations.CreateItineraries do
  use Ecto.Migration

  def change do
    create table(:itineraries) do
      add :name, :string
      add :description, :text
      add :start_date, :date
      add :end_date, :date
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:itineraries, [:user_id, :name, :start_date, :end_date])
  end
end
