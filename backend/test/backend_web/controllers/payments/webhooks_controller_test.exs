defmodule BackendWeb.PaymentsControllerTest do
  use BackendWeb.ConnCase, async: true

  test "liqpay payment", _ctx do
    # ctx =
    #   ctx |> produce([:user, :project, :instructor, course: [:published], conn: [:user_session]])

    # conn =
    #   post(ctx.conn, ~p"/webhooks/liqpay/update", %{
    #     "data" => "{\"order_id\":\"12345\",\"status\":\"success\"}" |> Base.encode64(),
    #     "signature" => "test"
    #   })

    # assert json_response(conn, 200) == %{
    #          "message" => "Payment processed successfully"
    #        }
  end
end
