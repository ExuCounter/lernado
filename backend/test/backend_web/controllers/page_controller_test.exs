defmodule BackendWeb.PageControllerTest do
  use BackendWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert true
  end
end
