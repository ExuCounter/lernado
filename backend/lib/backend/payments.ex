defmodule Backend.Payments do
  def find_payment_by_id(id) do
    Backend.Repo.find_by_id(Backend.Instructors.Schema.InstructorPayment, id)
  end

  def find_payment_integration_by_id(id) do
    Backend.Repo.find_by_id(Backend.Instructors.Schema.PaymentIntegration, id)
  end

  def find_enabled_payment_integration_by_instructor_id(id) do
    payment_integration =
      id |> Backend.Payments.Queries.enabled_payment_integrations() |> Backend.Repo.one()

    case payment_integration do
      nil ->
        {:error, %{status: :not_found}}

      payment_integration ->
        {:ok, payment_integration}
    end
  end

  def retrieve_payment_integration_credentials(integration) do
    integration |> Map.get(:credentials)
  end

  defp create_pending_course_payment(course) do
    params = %{
      currency: course.currency,
      amount: course.price,
      payment_status: :pending,
      payment_type: :course_payment_from_student
    }

    Backend.Instructors.Schema.InstructorPayment.create_changeset(
      course,
      course.payment_integration,
      params
    )
    |> Backend.Repo.insert()
  end

  defp liqpay_status_mapper(status) do
    cond do
      status in ["success", "subscribed", "unsubscribed"] ->
        :succeeded

      status in ["error", "failure"] ->
        :failed

      true ->
        :pending
    end
  end

  defp liqpay_payment_external_params_mapper() do
    %{
      data: %{
        payment_status: [from: "status", map: &liqpay_status_mapper/1],
        external_id: [from: "transaction_id"],
        amount: [from: "amount", type: :decimal],
        currency: [from: "currency"]
      }
    }
  end

  def process_liqpay_payment(%{data: raw_data, signature: signature}) do
    data =
      raw_data
      |> Base.decode64!()
      |> Jason.decode!()

    payment_id = data["order_id"]

    with {:ok, payment} <- Backend.Payments.find_payment_by_id(payment_id),
         payment = Backend.Repo.preload(payment, [:course, :payment_integration]),
         credentials = Map.get(payment.payment_integration, :credentials),
         {:ok, data} <-
           Backend.Payments.Integrations.LiqPay.verify_signature(%{
             data: raw_data,
             signature: signature,
             private_key: credentials["private_key"]
           }) do
      # params = %{
      #   payment_status: liqpay_status_mapper(data["status"]),
      #   external_id: data["transaction_id"],
      #   amount: Decimal.from_float(data["amount"]),
      #   currency: data["currency"]
      # }
      params = Backend.MapParams.map(data, :data, liqpay_payment_external_params_mapper())
      dbg(params)

      with :ok <-
             Backend.Instructors.Schema.InstructorPayment.check_if_the_same_payment_data(
               payment,
               params
             ) do
        Backend.Instructors.Schema.InstructorPayment.update_changeset(payment, params)
        |> Backend.Repo.update()
      end
    end
  end

  def ensure_course_needs_payment_form(course) do
    if Decimal.compare(course.price, 0) == :gt do
      :ok
    else
      {:error, %{message: "Course is free", status: :bad_request}}
    end
  end

  def request_course_payment_form(course, user) do
    course = Backend.Repo.preload(course, [:project, :payment_integration])

    with :ok <- ensure_course_needs_payment_form(course),
         :ok <- Backend.Instructors.ensure_course_published(course),
         credentials = retrieve_payment_integration_credentials(course.payment_integration),
         {:ok, payment} <- create_pending_course_payment(course) do
      dbg(payment)

      case course.payment_integration do
        %{provider: :liqpay} ->
          params = %{
            action: "pay",
            currency: payment.currency,
            amount: payment.amount,
            description: "Course #{course.id} payment for #{user.id}"
          }

          form = Backend.Payments.Integrations.LiqPay.html_form(params, credentials)

          {:ok, form}
      end
    end
  end
end
