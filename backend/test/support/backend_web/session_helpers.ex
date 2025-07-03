defmodule BackendWeb.SessionHelpers do
  import Plug.Conn
  import Phoenix.ConnTest

  def init_user_session(conn, user, params \\ %{}) do
    conn
    |> assign(:current_user, user)
    |> assign(:session_role, params[:session_role])
    |> init_test_session(%{})
  end
end
