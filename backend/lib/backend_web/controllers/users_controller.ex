defmodule BackendWeb.UsersController do
  use BackendWeb, :controller

  def find(conn, %{"id" => nil}) do
    conn |> not_found_response()
  end

  def find(conn, params) do
    user = Backend.Users.find_by_id(params["id"])

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
    user = Backend.Users.find_by_id(params["id"])

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
          message =
            Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} ->
              Phoenix.HTML.Safe.to_iodata(msg) |> IO.iodata_to_binary()
            end)

          conn |> bad_request_response(message)
      end
    end
  end
end
