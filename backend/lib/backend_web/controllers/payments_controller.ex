defmodule BackendWeb.PaymentsController do
  use BackendWeb, :controller
  action_fallback BackendWeb.FallbackController

  def request_course_form(conn, params) do
    with {:ok, course} <- Backend.Instructors.find_course_by_id(params["course_id"]),
         {:ok, form} <- Backend.Payments.request_course_form(course, conn.assigns.current_user) do
      conn
      |> put_status(200)
      |> json(%{
        data: %{
          form: form
        }
      })
    end
  end
end
