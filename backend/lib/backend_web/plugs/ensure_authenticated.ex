defmodule BackendWeb.Plugs.EnsureAuthenticated do
  import Plug.Conn

  def init(opts), do: opts

  def call(
        %Plug.Conn{assigns: %{current_user: _current_user, session_role: _session_role}} = conn,
        _opts
      ) do
    conn
  end

  def call(conn, _opts) do
    current_user = get_session(conn, :current_user)
    session_role = get_session(conn, :session_role)

    if is_nil(current_user) or is_nil(session_role) do
      conn |> put_status(403)
    else
      conn |> assign(:current_user, current_user) |> assign(:session_role, session_role)
    end
  end
end
