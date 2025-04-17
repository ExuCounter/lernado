defmodule Backend.Auth do
  defdelegate register(attrs), to: Backend.Users, as: :create_user

  def verify_user_credentials(email, password) do
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
end
