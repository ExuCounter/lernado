defmodule Backend.Students.Schema.StudentPayment do
  use Backend, :schema

  @derive {Jason.Encoder,
           only: [
             :id,
             :amount,
             :currency,
             :external_id,
             :payment_status
           ]}
  schema "student_payments" do
    field :amount, :decimal
    field :currency, :string
    field :external_id, :integer

    field(:payment_status, Ecto.Enum,
      values: [
        :pending,
        :succeeded,
        :failed
      ]
    )

    belongs_to :student, Backend.Students.Schema.Student
    belongs_to :course, Backend.Instructors.Schema.Course

    belongs_to :instructor_payment, Backend.Instructors.Schema.InstructorPayment
    belongs_to :payment_integration, Backend.Instructors.Schema.PaymentIntegration

    timestamps()
  end

  def create_changeset(student, course, payment_integration, attrs) do
    %__MODULE__{}
    |> cast(attrs, [:amount, :currency, :payment_status])
    |> put_assoc(:student, student)
    |> put_assoc(:course, course)
    |> put_assoc(:payment_integration, payment_integration)
    |> validate_required([:amount, :currency, :payment_status])
  end

  def update_changeset(payment, attrs) do
    payment
    |> cast(attrs, [:payment_status, :external_id])
    |> validate_required([:payment_status, :external_id])

    # payment
    # |> cast(attrs, [:payment_status, :external_id])
    # |> validate_required([:payment_status, :external_id])
  end

  def link_instructor_payment_changeset(student_payment, instructor_payment) do
    student_payment
    |> cast(%{}, [])
    |> put_assoc(:instructor_payment, instructor_payment)
  end

  def check_if_the_same_payment_data(payment, %{
        amount: amount,
        currency: currency
      }) do
    with true <- Decimal.equal?(payment.amount, amount),
         true <- payment.currency == currency do
      :ok
    else
      _ -> {:error, %{message: "Payment data mismatch.", status: :invalid_field}}
    end
  end
end
