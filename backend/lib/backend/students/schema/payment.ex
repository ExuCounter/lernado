defmodule Backend.Students.Schema.Payment do
  use Backend, :schema

  schema "student_payments" do
    field :amount, :decimal
    field :currency, :string

    field(:payment_status, Ecto.Enum,
      values: [
        :pending,
        :succeeded,
        :failed
      ]
    )

    belongs_to :student, Backend.Students.Schema.Student
    belongs_to :course, Backend.Instructors.Schema.Course

    belongs_to :payment_integration, Backend.Instructors.Schema.PaymentIntegration
    belongs_to :instructor_payment, Backend.Instructors.Schema.InstructorPayment

    timestamps()
  end

  def create_changeset(student, course, attrs) do
    %__MODULE__{}
    |> cast(attrs, [:amount, :currency, :payment_status])
    |> put_assoc(:student, student)
    |> put_assoc(:course, course)
    |> put_assoc(:payment_integration, course.payment_integration)
    |> validate_required([:amount, :currency, :status, :payment_method])
  end
end
