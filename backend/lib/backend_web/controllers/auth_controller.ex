defmodule BackendWeb.AuthController do
  use BackendWeb, :controller

  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, user} <- Backend.Users.verify_user(email, password) do
      conn
      |> put_session(:current_user, user)
      |> put_status(201)
      |> json(%{
        message: "User logged in successfully.",
        status: "success"
      })
    else
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
    with {:ok, user} <- Backend.Users.create_user(params) do
      conn
      |> put_session(:current_user, user)
      |> put_status(201)
      |> json(%{
        message: "User created successfully.",
        status: "success"
      })
    else
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
