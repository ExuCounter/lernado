defmodule Backend.Instructors.Schema.InstructorPayment do
  use Backend, :schema

  schema "instructor_payments" do
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

    field :payment_type, Ecto.Enum,
      values: [
        :course_payment_from_student
      ]

    belongs_to :instructor, Backend.Instructors.Schema.Instructor
    belongs_to :course, Backend.Instructors.Schema.Course

    belongs_to :payment_integration, Backend.Instructors.Schema.PaymentIntegration

    has_one :student_payment, Backend.Students.Schema.StudentPayment

    timestamps()
  end

  def create_changeset(course, payment_integration, attrs) do
    %__MODULE__{
      instructor_id: payment_integration.instructor_id
    }
    |> cast(attrs, [:amount, :currency, :payment_status, :payment_type, :external_id])
    |> validate_required([:amount, :currency, :payment_status, :payment_type])
    |> validate_number(:amount, greater_than: 0)
    |> validate_length(:currency, is: 3)
    |> put_assoc(:course, course)
    |> put_assoc(:payment_integration, payment_integration)
    |> foreign_key_constraint(:instructor_id)
  end

  def update_changeset(payment, attrs) do
    payment
    |> cast(attrs, [:payment_status, :external_id])
    |> validate_required([:payment_status, :external_id])
  end
end
