defmodule CoPlanHub.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :guid, :uuid, null: false
      add :filename, :string
      add :description, :text
      add :bytes, :binary

      timestamps(type: :utc_datetime)
    end

    alter table(:itineraries) do
      add :location, :string
      add :budget, :decimal
      add :image_id, references(:images, on_delete: :nilify_all)
    end

    create index(:itineraries, [:image_id])

    alter table(:users) do
      add :image_id, references(:images, on_delete: :nilify_all)
    end

    create index(:users, [:image_id])
  end
end
