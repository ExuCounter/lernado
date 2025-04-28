defmodule BackendWeb.UsersController do
  use BackendWeb, :controller
  action_fallback BackendWeb.FallbackController

  def find(conn, params) do
    with {:ok, user} <- Backend.Users.find_by_id(params["user_id"]) do
      conn
      |> put_status(200)
      |> json(%{
        data: %{
          user: user
        }
      })
    end
  end

  def update(conn, params) do
    with {:ok, user} <- Backend.Users.find_by_id(params["user_id"]),
         :ok <-
           Bodyguard.permit(Backend.Users, :update_user, conn.assigns.current_user, %{
             user: user
           }),
         {:ok, user} <- Backend.Users.update_user(user, params) do
      conn
      |> put_status(200)
      |> json(%{
        data: %{
          user: user
        }
      })
    end
  end
end
