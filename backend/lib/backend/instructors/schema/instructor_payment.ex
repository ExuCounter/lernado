defmodule Backend.Instructors.Schema.InstructorPayment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "instructor_payments" do
    field :amount, :decimal
    field :currency, :string
    field :external_id, :binary_id
    field :status, Backend.Instructors.Payments.TransactionStatus
    field :type, Backend.Instructors.Payments.TransactionType

    belongs_to(:instructor, Backend.Instructors.Schema.Instructor, type: :binary_id)
    belongs_to(:course, Backend.Instructors.Schema.Course, type: :binary_id)

    belongs_to(:payment_integration, Backend.Instructors.Schema.PaymentIntegration,
      type: :binary_id
    )

    timestamps()
  end

  def create_changeset(course, payment_integration, attrs) do
    %__MODULE__{
      course_id: course.id,
      instructor_id: course.project.instructor_id,
      payment_integration_id: payment_integration.id
    }
    |> cast(attrs, [:amount, :currency, :status, :type])
    |> validate_required([:amount, :currency, :status, :type])
    |> validate_number(:amount, greater_than: 0)
    |> validate_length(:currency, is: 3)
    |> foreign_key_constraint(:instructor_id)
    |> foreign_key_constraint(:course_id)
    |> foreign_key_constraint(:payment_integration_id)
  end

  def update_changeset(payment, attrs) do
    payment
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end
