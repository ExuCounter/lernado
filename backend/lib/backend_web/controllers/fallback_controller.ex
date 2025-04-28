defmodule BackendWeb.FallbackController do
  import BackendWeb.ResponseHelpers
  use Phoenix.Controller

  def call(conn, {:error, %{status: :not_found}}) do
    conn |> not_found_response()
  end

  def call(conn, {:error, :unauthorized}) do
    conn |> forbidden_response()
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn |> failed_changeset_response(changeset)
  end
end
