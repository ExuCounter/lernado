defmodule BackendWeb.PaymentsTest do
  use BackendWeb.ConnCase, async: true

  test "liqpay payment", ctx do
    ctx1 =
      ctx
      |> produce([
        :user,
        :instructor,
        :project,
        :course
      ])
      |> exec(:create_payment_integration,
        provider: :liqpay,
        credentials: %{
          public_key: "public_key",
          private_key: "private_key"
        }
      )

    ctx2 =
      ctx
      |> produce([
        :user,
        :student,
        conn: [:user_session]
      ])

    conn =
      post(ctx2.conn, ~p"/api/payments/request-course-form", %{
        "course_id" => ctx1.course.id,
        "user_id" => ctx2.user.id
      })

    assert %{
             "message" => "Course is free"
           } = json_response(conn, 400)

    ctx1 =
      ctx1
      |> exec(:update_course, public_path: "course_path", currency: "USD", price: 100.0)
      |> exec(:enable_payments_for_course)
      |> exec(:publish_course)

    conn =
      post(ctx2.conn, ~p"/api/payments/request-course-form", %{
        "course_id" => ctx1.course.id,
        "user_id" => ctx2.user.id
      })

    assert %{
             "data" => %{
               "form" => form
             }
           } = json_response(conn, 200)

    assert String.contains?(form, Backend.Payments.Integrations.LiqPay.checkout_url())
    assert String.contains?(form, "Pay with LiqPay")
  end
end
