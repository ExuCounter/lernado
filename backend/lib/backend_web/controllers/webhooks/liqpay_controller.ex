defmodule BackendWeb.Webhooks.LiqPayController do
  use BackendWeb, :controller
  action_fallback BackendWeb.Webhooks.FallbackController

  def update_or_create(conn, params) do
    with {:ok, _data} <-
           Backend.Payments.process_liqpay_payment(%{
             data: params["data"],
             signature: params["signature"]
           }) do
      conn
      |> put_status(200)
      |> json(%{
        message: "Payment processed successfully."
      })
    end
  end
end
