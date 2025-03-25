defmodule BackendWeb.AuthController do
  use BackendWeb, :controller

  def login(conn, %{"email" => email, "password" => password}) do
    result = Backend.Users.verify_user(email, password)

    case result do
      {:ok, user} ->
        conn |> put_session(:current_user, user) |> put_status(201)

      {:error, message} ->
        conn
        |> put_status(401)
        |> json(%{
          message: message,
          status: "error"
        })
    end
  end

  def register(conn, params) do
    result = Backend.Users.create_user(params)

    case result do
      {:ok, user} ->
        conn |> put_session(:current_user, user) |> put_status(201)

      {:error, _changeset} ->
        conn
        |> put_status(400)
        |> json(%{
          message: "Something went wrong.",
          status: "error"
        })
    end
  end
end
