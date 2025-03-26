defmodule BackendWeb.SessionHelpers do
  import Plug.Conn
  import Phoenix.ConnTest

  def init_user_session(conn, user) do
    conn |> assign(:current_user, user) |> init_test_session(%{})
  end
end
