defmodule BackendWeb.UsersController do
  use BackendWeb, :controller

  def update(conn, %{"id" => nil}) do
    conn
    |> put_status(400)
    |> json(%{
      message: "User ID is required.",
      status: "error"
    })
  end

  def update(conn, params) do
    user = Backend.Users.find_by_id(params["id"])

    if is_nil(user) do
      conn
      |> put_status(404)
      |> json(%{
        message: "User not found.",
        status: "error"
      })
    else
      with {:ok, user} <- Backend.Users.update_user(user, params),
           true <- Backend.Users.authorize(:update_user, conn.assigns.current_user, %{user: user}) do
        conn
        |> put_status(200)
        |> json(%{
          user: user,
          message: "User updated successfully.",
          status: "success"
        })
      else
        false ->
          conn
          |> put_status(403)
          |> json(%{
            message: "You are not authorized to perform this action.",
            status: "error"
          })

        {:error, changeset} ->
          conn
          |> put_status(400)
          |> json(%{
            message:
              Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} ->
                Phoenix.HTML.Safe.to_iodata(msg) |> IO.iodata_to_binary()
              end),
            status: "error"
          })
      end
    end
  end
end
