defmodule BackendWeb.SessionHelpers do
  # import Plug.Conn
  import Phoenix.ConnTest

  def init_user_session(conn, user) do
    init_test_session(conn, user)
  end
end
