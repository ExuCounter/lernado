defmodule Backend.Users do
  defdelegate authorize(action, user, params), to: Backend.Users.Policy

  def create_user(attrs) do
    attrs
    |> Backend.Users.Schema.User.create_changeset()
    |> Backend.Repo.insert()
  end

  def create_user!(attrs) do
    attrs
    |> Backend.Users.Schema.User.create_changeset()
    |> Backend.Repo.insert!()
  end

  def update_user(user, attrs) do
    user
    |> Backend.Users.Schema.User.update_changeset(attrs)
    |> Backend.Repo.update()
  end

  def find_by_id(id) do
    Backend.Repo.find_by_id(Backend.Users.Schema.User, id)
  end
end
