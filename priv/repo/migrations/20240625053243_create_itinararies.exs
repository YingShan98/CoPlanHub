defmodule CoPlanHub.Repo.Migrations.CreateItinararies do
  use Ecto.Migration

  def change do
    create table(:itinararies) do
      add :name, :string
      add :description, :text
      add :start_date, :date
      add :end_date, :date
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:itinararies, [:user_id, :name, :start_date, :end_date])
  end
end
