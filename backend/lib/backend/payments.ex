defmodule Backend.Payments do
  def find_instructor_payment_by_id(id) do
    Backend.Repo.find_by_id(Backend.Instructors.Schema.InstructorPayment, id)
  end

  def find_student_payment_by_id(id) do
    Backend.Repo.find_by_id(Backend.Students.Schema.StudentPayment, id)
  end

  def find_payment_by_type(%{"id" => id, "type" => type}) do
    case type do
      "student" ->
        find_student_payment_by_id(id)

      "instructor" ->
        find_instructor_payment_by_id(id)
    end
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

  # They are identical for now
  def map_student_payment_status_to_instructor_payment_status(payment_status) do
    payment_status
  end

  def create_instructor_course_payment_from_student_payment(student_payment) do
    params =
      %{
        currency: student_payment.currency,
        amount: student_payment.amount,
        payment_type: :course_payment_from_student,
        payment_status:
          map_student_payment_status_to_instructor_payment_status(student_payment.payment_status),
        external_id: student_payment.external_id
      }

    student_payment = student_payment |> Backend.Repo.preload(course: :payment_integration)

    Backend.Instructors.Schema.InstructorPayment.create_changeset(
      student_payment.course,
      student_payment.course.payment_integration,
      params
    )
    |> Backend.Repo.insert()
  end

  def create_student_course_payment_pending(student, course) do
    params = %{
      currency: course.currency,
      amount: course.price,
      payment_status: :pending,
      payment_type: :course_payment_from_student
    }

    course = Backend.Repo.preload(course, :payment_integration)

    Backend.Students.Schema.StudentPayment.create_changeset(
      student,
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

  defp base64_to_json(base64) do
    base64
    |> Base.decode64!()
    |> Jason.decode!()
  end

  def process_liqpay_student_payment(
        data,
        %Backend.Students.Schema.StudentPayment{} = student_payment
      ) do
    student_payment = student_payment |> Backend.Repo.preload(:course)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:check_if_the_same_payment_data, fn _repo, _changes ->
      with :ok <-
             Backend.Students.Schema.StudentPayment.check_if_the_same_payment_data(
               student_payment,
               %{
                 amount: data["amount"],
                 currency: data["currency"]
               }
             ) do
        {:ok, nil}
      end
    end)
    |> Ecto.Multi.run(:update_student_payment, fn _repo, _changes ->
      params =
        Backend.MapParams.map(data, :data, %{
          data: %{
            payment_status: [from: "status", map: &liqpay_status_mapper/1],
            external_id: [from: "transaction_id"]
          }
        })

      student_payment
      |> Backend.Students.Schema.StudentPayment.update_changeset(params)
      |> Backend.Repo.update()
    end)
    |> Ecto.Multi.run(:create_instructor_payment, fn _repo,
                                                     %{update_student_payment: student_payment} ->
      create_instructor_course_payment_from_student_payment(student_payment)
    end)
    |> Ecto.Multi.run(:link_instructor_payment_to_student_payment, fn _repo,
                                                                      %{
                                                                        create_instructor_payment:
                                                                          instructor_payment,
                                                                        update_student_payment:
                                                                          student_payment
                                                                      } ->
      student_payment
      |> Backend.Repo.preload(:instructor_payment)
      |> Backend.Students.Schema.StudentPayment.link_instructor_payment_changeset(
        instructor_payment
      )
      |> Backend.Repo.update()
    end)
    |> Backend.Repo.transaction()
    |> case do
      {:ok, %{link_instructor_payment_to_student_payment: student_payment}} ->
        {:ok, student_payment}

      {:error, error} ->
        {:error, error}
    end
  end

  def process_liqpay_payment(%{data: raw_data, signature: signature}) do
    data = base64_to_json(raw_data)

    with {:ok, payment} <- Backend.Payments.find_payment_by_type(data["order_id"]),
         payment = Backend.Repo.preload(payment, [:course, :payment_integration]),
         credentials = Map.get(payment.payment_integration, :credentials),
         {:ok, data} <-
           Backend.Payments.Integrations.LiqPay.verify_signature(%{
             data: raw_data,
             signature: signature,
             private_key: credentials["private_key"]
           }) do
      process_liqpay_student_payment(data, payment)
    end
  end

  def ensure_course_needs_payment_form(course) do
    if Decimal.compare(course.price, 0) == :gt do
      :ok
    else
      {:error, %{message: "Course is free", status: :bad_request}}
    end
  end

  def request_course_payment_form(course, student) do
    course = Backend.Repo.preload(course, [:project, :payment_integration])

    with :ok <- ensure_course_needs_payment_form(course),
         :ok <- Backend.Instructors.ensure_course_published(course) do
      Ecto.Multi.new()
      |> Ecto.Multi.run(:student_payment, fn _repo, _changes ->
        create_student_course_payment_pending(student, course)
      end)
      |> Backend.Repo.transaction()
      |> case do
        {:ok, %{student_payment: student_payment}} ->
          case course.payment_integration do
            %{provider: :liqpay} ->
              params = %{
                action: "pay",
                currency: student_payment.currency,
                amount: student_payment.amount,
                description: "Course #{course.id} payment for #{student.id}",
                order_id:
                  %{
                    id: student_payment.id,
                    type: :student
                  }
                  |> Jason.encode!()
              }

              credentials = course.payment_integration |> Map.get(:credentials)

              html_form = Backend.Payments.Integrations.LiqPay.html_form(params, credentials)

              {:ok,
               %{
                 html_form: html_form,
                 student_payment: student_payment
               }}
          end

        {:error, error} ->
          IO.inspect(error)
          {:error, :bad_request}
      end
    end
  end
end
