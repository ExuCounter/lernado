defmodule BackendWeb.PaymentsControllerTest do
  use BackendWeb.ConnCase, async: true
  # data #=> %{
  # "mpi_eci" => "7",
  # "currency_credit" => "UAH",
  # "commission_credit" => 63.03,
  # "action" => "pay",
  # "sender_card_mask2" => "537541*29",
  # "liqpay_order_id" => "1WPXS9UP1750688808146416",
  # "paytype" => "gpaycard",
  # "type" => "buy",
  # "transaction_id" => 2666702926,
  # "order_id" => "d0a20dcb-dd03-49e0-9d07-1fe67c1e94b6",
  # "commission_debit" => 0.0,
  # "amount_bonus" => 0.0,
  # "sender_card_type" => "mc",
  # "amount_debit" => 4201.68,
  # "end_date" => 1750688808307,
  # "status" => "success",
  # "is_3ds" => false,
  # "description" => "LiqPay payment",
  # "public_key" => "sandbox_i7433770906",
  # "amount_credit" => 4201.68,
  # "payment_id" => 2666702926,
  # "agent_commission" => 0.0,
  # "currency" => "USD",
  # "sender_card_bank" => "JSC UNIVERSAL BANK",
  # "receiver_commission" => 1.5,
  # "sender_commission" => 0.0,
  # "language" => "en",
  # "create_date" => 1750688799500,
  # "currency_debit" => "UAH",
  # "sender_card_country" => 804,
  # "ip" => "176.37.165.243",
  # "amount" => 100.0,
  # "acq_id" => 414963,
  # "sender_bonus" => 0.0,
  # "version" => 3
  # }

  describe "liqpay payment" do
    setup ctx do
      ctx
      |> produce([
        :instructor_payment,
        :student,
        course: [:published],
        conn: [:user_session]
      ])
    end

    test "success", ctx do
      data = %{
        order_id: ctx.instructor_payment.id,
        status: "success",
        amount: ctx.instructor_payment.amount,
        currency: ctx.instructor_payment.currency,
        transaction_id: Faker.random_between(1, 1_000_000_000)
      }

      # Backend.Payments.request_course_payment_form(ctx.course, ctx.student)

      base64_data = data |> Jason.encode!() |> Base.encode64()

      credentials = ctx.payment_integration |> Map.get(:credentials)

      signature =
        Backend.Payments.Integrations.LiqPay.create_signature(
          base64_data,
          credentials["private_key"]
        )

      conn =
        post(ctx.conn, ~p"/webhooks/liqpay/update", %{
          "data" => data |> Jason.encode!() |> Base.encode64(),
          "signature" => signature
        })

      assert json_response(conn, 200) == %{
               "message" => "Payment processed successfully."
             }

      _instructor_payment =
        ctx.instructor_payment |> Backend.Repo.reload!() |> Backend.Repo.preload(:student_payment)
    end

    test "failure due to payment data mismatch", ctx do
      data = %{
        order_id: ctx.instructor_payment.id,
        status: "success",
        amount: "200.00",
        currency: "UAH",
        transaction_id: Faker.random_between(1, 1_000_000_000)
      }

      base64_data = data |> Jason.encode!() |> Base.encode64()

      credentials = ctx.payment_integration |> Map.get(:credentials)

      signature =
        Backend.Payments.Integrations.LiqPay.create_signature(
          base64_data,
          credentials["private_key"]
        )

      conn =
        post(ctx.conn, ~p"/webhooks/liqpay/update", %{
          "data" => data |> Jason.encode!() |> Base.encode64(),
          "signature" => signature
        })

      assert json_response(conn, 422) == %{
               "message" => "Payment data mismatch."
             }
    end

    test "failure due to signature mismatch", ctx do
      data = %{
        order_id: ctx.instructor_payment.id,
        status: "success",
        amount: "200.00",
        currency: "UAH",
        transaction_id: Faker.random_between(1, 1_000_000_000)
      }

      signature = "WRONG SIGNATURE"

      conn =
        post(ctx.conn, ~p"/webhooks/liqpay/update", %{
          "data" => data |> Jason.encode!() |> Base.encode64(),
          "signature" => signature
        })

      assert json_response(conn, 422) == %{
               "message" => "Invalid signature."
             }
    end
  end
end
