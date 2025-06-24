defmodule Backend.Payments.Integrations.LiqPay do
  @moduledoc """
  This module handles the LiqPay payment provider integration.
  """

  @checkout_url "https://www.liqpay.ua/api/3/checkout"

  def checkout_url(), do: @checkout_url

  def create_signature(data, private_key) do
    hash_data = private_key <> data <> private_key

    :crypto.hash(:sha, hash_data)
    |> Base.encode64()
  end

  @spec verify_signature(%{
          data: String.t(),
          signature: String.t(),
          private_key: String.t()
        }) :: {:ok, map()} | {:error, :invalid_signature}
  def verify_signature(%{data: data, signature: signature, private_key: private_key}) do
    own_signature = create_signature(data, private_key)

    if signature == own_signature do
      data = data |> Base.decode64!() |> Jason.decode!()

      {:ok, data}
    else
      {:error, %{message: "Invalid signature.", status: :invalid_field}}
    end
  end

  defp prepare_order_data(params, keys) do
    data =
      params
      |> Map.merge(%{
        "version" => "3",
        "public_key" => keys["public_key"],
        "server_url" => "#{BackendWeb.Endpoint.url()}/webhooks/liqpay/update"
      })
      |> Jason.encode!()
      |> Base.encode64()

    signature = create_signature(data, keys["private_key"])

    %{
      data: data,
      signature: signature
    }
  end

  defp prepare_html_form(%{data: data, signature: signature}) do
    "<form method=\"POST\" action=\"#{@checkout_url}\" accept-charset=\"utf-8\" >
      <input type=\"hidden\" name=\"data\" value=\"#{data}\" />
      <input type=\"hidden\" name=\"signature\" value=\"#{signature}\" />
      <button type=\"submit\" class=\"liqpay-button\">Pay with LiqPay</button>
    </form>
    "
  end

  @spec prepare_order_data(
          %{
            action: String.t(),
            amount: number(),
            currency: String.t(),
            description: String.t(),
            order_id: String.t()
          },
          %{
            public_key: String.t(),
            private_key: String.t()
          }
        ) :: %{
          data: String.t(),
          signature: String.t()
        }
  def html_form(params, keys) do
    prepare_order_data(params, keys)
    |> prepare_html_form()
  end
end
