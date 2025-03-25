defmodule BackendWeb.Plugs.EnsureAuthenticated do
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{assigns: %{current_user: _current_user}} = conn, _opts), do: conn

  def call(conn, _opts) do
    conn |> put_status(401) |> halt()
  end
end
