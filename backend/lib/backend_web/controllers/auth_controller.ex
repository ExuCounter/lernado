defmodule BackendWeb.AuthController do
  use BackendWeb, :controller
  action_fallback BackendWeb.FallbackController

  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, user} <- Backend.Auth.verify_user_credentials(email, password) do
      conn
      |> put_session(:current_user, user)
      |> successful_response(%{user: user})
    end
  end

  def register(conn, params) do
    with {:ok, user} <- Backend.Auth.register(params) do
      conn
      |> put_session(:current_user, user)
      |> successful_response(%{user: user})
    end
  end
end
