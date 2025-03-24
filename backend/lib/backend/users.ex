defmodule Backend.Users do
  def create_user(attrs) do
    attrs
    |> Backend.Users.Schema.User.create_changeset()
    |> Backend.Repo.insert()
  end

  def update_user(user, attrs) do
    user
    |> Backend.Users.Schema.User.update_changeset(attrs)
    |> Backend.Repo.update!()
  end
end
