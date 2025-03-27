defmodule Backend.Users do
  defdelegate authorize(action, user, params), to: Backend.Users.Policy

  def create_user(attrs) do
    attrs
    |> Backend.Users.Schema.User.create_changeset()
    |> Backend.Repo.insert()
  end

  def update_user(user, attrs) do
    user
    |> Backend.Users.Schema.User.update_changeset(attrs)
    |> Backend.Repo.update()
  end

  def verify_user(email, password) do
    user = Backend.Repo.get_by(Backend.Users.Schema.User, email: email)

    case user do
      nil ->
        {:error, "Invalid email or password"}

      user ->
        case Argon2.verify_pass(password, user.password_hash) do
          true ->
            {:ok, user}

          false ->
            {:error, "Invalid email or password"}
        end
    end
  end

  def find_by_id(id) do
    Backend.Repo.get_by(Backend.Users.Schema.User, id: id)
  end
end
