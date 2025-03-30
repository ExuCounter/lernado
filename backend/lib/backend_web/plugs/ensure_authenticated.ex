defmodule BackendWeb.Plugs.EnsureAuthenticated do
  import Plug.Conn
  import BackendWeb.ResponseHelpers

  def init(opts), do: opts

  def call(%Plug.Conn{assigns: %{current_user: _current_user}} = conn, _opts), do: conn

  def call(conn, _opts) do
    current_user = get_session(conn, :current_user)

    if is_nil(current_user) do
      conn |> unauthorized_response() |> halt()
    else
      assign(conn, :current_user, current_user)
    end
  end
end
