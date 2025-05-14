defmodule BackendWeb.FallbackController do
  use Phoenix.Controller

  def call(conn, {:error, %{status: :not_found, message: message}}) do
    conn
    |> put_status(404)
    |> json(%{
      message: message
    })
  end

  def call(conn, {:error, %{status: :bad_request, message: message}}) do
    conn
    |> put_status(400)
    |> json(%{
      message: message
    })
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(403)
    |> json(%{
      message: "You are not authorized to perform this action."
    })
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(400)
    |> json(%{
      message: BackendWeb.Helpers.ErrorHelpers.traverse_errors(changeset)
    })
  end
end
