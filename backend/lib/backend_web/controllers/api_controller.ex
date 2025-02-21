defmodule BackendWeb.APIController do
  use BackendWeb, :controller

  def dummy(conn, params) do
    conn
    |> json(%{
      message: "Dummy #{params["id"]}. It's response from the backend!!!",
      status: "success"
    })
  end
end
