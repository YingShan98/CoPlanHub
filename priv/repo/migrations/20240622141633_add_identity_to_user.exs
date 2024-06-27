defmodule CoPlanHub.Repo.Migrations.AddIdentityToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :guid, :uuid, null: false
      add :username, :string
      add :first_name, :string
      add :last_name, :string
      add :profile_image, :binary
    end
  end
end
