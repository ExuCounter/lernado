defmodule BackendWeb.PaymentsController do
  use BackendWeb, :controller
  action_fallback BackendWeb.FallbackController

  def request_course_form(conn, params) do
    with {:ok, course} <- Backend.Instructors.find_course_by_id(params["course_id"]),
         current_user = conn.assigns.current_user |> Backend.Repo.preload(:student),
         {:ok, %{html_form: html_form}} <-
           Backend.Payments.request_course_payment_form(course, current_user.student) do
      conn
      |> put_status(200)
      |> json(%{
        data: %{
          form: html_form
        }
      })
    end
  end
end
