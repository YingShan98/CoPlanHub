defmodule CoPlanHub.Repo.Migrations.MigrateUserImages do
  use Ecto.Migration

  alias CoPlanHub.Repo
  alias CoPlanHub.Accounts.User
  alias CoPlanHub.Attachments.Image
  import Ecto.Query

  def up do
    Repo.transaction(fn ->
      Repo.all(from u in User, where: not is_nil(u.profile_image), select: {u.id, u.profile_image})
      |> Enum.each(fn {user_id, bytes} ->
        %Image{bytes: bytes}
        |> Repo.insert!()
        |> case do
          %Image{id: image_id} ->
            from(u in User, where: u.id == ^user_id)
            |> Repo.update_all(set: [image_id: image_id])
        end
      end)
    end)
  end

  def down do
    Repo.transaction(fn ->
      Repo.all(from u in User, where: not is_nil(u.image_id), select: {u.id, u.image_id})
      |> Enum.each(fn {user_id, image_id} ->
        from(i in Image, where: i.id == ^image_id)
        |> Repo.delete_all()

        from(u in User, where: u.id == ^user_id)
        |> Repo.update_all(set: [image_id: nil])
      end)
    end)
  end
end
