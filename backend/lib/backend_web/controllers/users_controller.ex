defmodule BackendWeb.UsersController do
  use BackendWeb, :controller

  def find(conn, %{"id" => nil}) do
    conn |> not_found_response()
  end

  def find(conn, params) do
    user = Backend.Users.find_by_id(params["user_id"])

    if is_nil(user) do
      conn |> not_found_response()
    else
      conn |> successful_response(%{user: user})
    end
  end

  def update(conn, %{"id" => nil}) do
    conn |> not_found_response()
  end

  def update(conn, params) do
    user = Backend.Users.find_by_id(params["user_id"])

    if is_nil(user) do
      conn |> not_found_response()
    else
      with true <-
             Backend.Users.authorize(:update_user, conn.assigns.current_user, %{user: user}),
           {:ok, user} <- Backend.Users.update_user(user, params) do
        conn |> successful_response(%{user: user})
      else
        false ->
          conn |> forbidden_response()

        {:error, changeset} ->
          conn |> failed_changeset_response(changeset)
      end
    end
  end
end
