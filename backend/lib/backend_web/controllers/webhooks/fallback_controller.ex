defmodule BackendWeb.Webhooks.FallbackController do
  use Phoenix.Controller
  alias Ecto.Changeset

  def call(conn, {:error, :unauthorized}),
    do: conn |> put_status(401) |> json(%{message: "Unauthorized"})

  def call(conn, {:error, %{message: message, status: :invalid_field}}),
    do: conn |> put_status(422) |> json(%{message: message})

  def call(conn, {:error, %{message: message, status: :missing_required_field}}),
    do: conn |> put_status(422) |> json(%{message: message})

  def call(conn, {:error, %Changeset{} = changeset}) do
    conn
    |> put_status(422)
    |> json(%{message: BackendWeb.Helpers.ErrorHelpers.traverse_errors(changeset)})
  end

  def call(conn, error),
    do: conn |> put_status(422) |> json(%{message: "Cannot process request: #{inspect(error)}"})
end
