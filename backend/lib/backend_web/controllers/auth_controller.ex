defmodule BackendWeb.AuthController do
  use BackendWeb, :controller

  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, user} <- Backend.Users.verify_user(email, password) do
      conn
      |> put_session(:current_user, user)
      |> successful_response()
    else
      {:error, message} ->
        conn |> unauthorized_response(message)
    end
  end

  def register(conn, params) do
    with {:ok, user} <- Backend.Users.create_user(params) do
      conn
      |> put_session(:current_user, user)
      |> successful_response()
    else
      {:error, _changeset} ->
        conn |> unauthorized_response()
    end
  end
end
