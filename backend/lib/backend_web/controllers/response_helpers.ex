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

  def unauthorized_response(conn, message \\ @unauthorized_message) do
    conn
    |> put_status(401)
    |> json(%{
      message: message
    })
  end

  def assert_forbidden_response(conn, message \\ @forbidden_message) do
    assert conn.status == 403

    assert %{
             "message" => ^message
           } =
             Jason.decode!(conn.resp_body)
  end

  def assert_not_found_response(conn, message \\ @not_found_message) do
    assert conn.status == 404

    assert %{
             "message" => ^message
           } =
             Jason.decode!(conn.resp_body)
  end

  def assert_bad_request_response(conn, message \\ @bad_request_message) do
    assert conn.status == 400

    assert %{
             "message" => ^message
           } =
             Jason.decode!(conn.resp_body)
  end

  def assert_unauthorized_response(conn, message \\ @unauthorized_message) do
    assert conn.status == 401

    assert %{
             "message" => ^message
           } =
             Jason.decode!(conn.resp_body)
  end
end
