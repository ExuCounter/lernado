defmodule Backend.Payments do
  def find_payment_by_id(id) do
    Backend.Repo.find_by_id(Backend.Instructors.Payments.InstructorPayment, id: id)
  end

  def find_payment_integration_by_id(id) do
    Backend.Repo.find_by_id(Backend.Instructors.Schema.PaymentIntegration, id)
  end

  def find_course_payment_integration(course) do
    case course.payment_integration_id do
      nil ->
        {:error, %{status: :not_found, message: "Payment integration is not found."}}

      payment_integration_id ->
        find_payment_integration_by_id(payment_integration_id)
    end
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

  defp create_pending_course_payment(course, payment_integration) do
    params = %{
      currency: course.currency,
      amount: course.price,
      status: :pending,
      type: :course_payment_from_student
    }

    Backend.Instructors.Schema.InstructorPayment.create_changeset(
      course,
      payment_integration,
      params
    )
    |> Backend.Repo.insert()
  end

  def process_liqpay_payment(%{data: raw_data, signature: signature}) do
    data =
      raw_data
      |> Base.decode64!()
      |> Jason.decode!()

    payment_id = data["order_id"]

    with {:ok, payment} <- Backend.Payments.find_payment_by_id(payment_id),
         payment = Backend.Repo.preload(payment, [:course, :payment_integration]),
         {:ok, credentials} <-
           retrieve_payment_integration_credentials(payment.payment_integration),
         {:ok, data} <-
           Backend.Payments.Integrations.LiqPay.verify_signature(%{
             data: raw_data,
             signature: signature,
             private_key: credentials.private_key
           }) do
      params = %{
        status: data.status
      }

      Backend.Instructors.Schema.InstructorPayment.update_changeset(payment, params)
    end
  end

  def course_needs_payment_form(course) do
    if Decimal.compare(course.price, 0) == :gt do
      :ok
    else
      {:error, %{message: "Course is free", status: :bad_request}}
    end
  end

  def request_course_payment_form(course, user) do
    course = Backend.Repo.preload(course, :project)

    with :ok <- course_needs_payment_form(course),
         :ok <- Backend.Instructors.ensure_course_published(course),
         {:ok, payment_integration} <- find_course_payment_integration(course),
         credentials = retrieve_payment_integration_credentials(payment_integration),
         {:ok, payment} <- create_pending_course_payment(course, payment_integration) do
      case payment_integration do
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
