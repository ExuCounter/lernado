defmodule BackendWeb.ResponseHelpers do
  use ExUnit.CaseTemplate
  import Plug.Conn
  import Phoenix.Controller

  @not_found_message "Resource not found."
  @bad_request_message "Something went wrong."
  @unauthorized_message "Unauthorized."
  @forbidden_message "You are not authorized to perform this action."

  def successful_response(conn, data \\ %{}) do
    conn
    |> put_status(200)
    |> json(%{
      data: data
    })
  end

  def forbidden_response(conn, message \\ @forbidden_message) do
    conn
    |> put_status(403)
    |> json(%{
      message: message
    })
  end

  def not_found_response(conn, message \\ @not_found_message) do
    conn
    |> put_status(404)
    |> json(%{
      message: message
    })
  end

  def bad_request_response(conn, message \\ @bad_request_message) do
    conn
    |> put_status(400)
    |> json(%{
      message: message
    })
  end

  def failed_changeset_response(conn, changeset) do
    message =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
          opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
        end)
      end)

    conn |> bad_request_response(message)
  end
end
