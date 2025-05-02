defmodule Backend.Instructors.Payments.InstructorPayment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "instructor_payments" do
    field :usd_amount, :decimal
    field :currency, :string
    field :provider_payment_id, :binary_id
    field :provider, :string
    field :status, Backend.Instructors.Payments.TransactionStatus
    field :type, Backend.Instructors.Payments.TransactionType

    belongs_to(:instructor, Backend.Instructors.Schema.Instructor)
    belongs_to(:course, Backend.Instructors.Schema.Course)

    timestamps()
  end

  def create_changeset(course, attrs) do
    %__MODULE__{
      course_id: course.id,
      instructor_id: course.instructor_id
    }
    |> cast(attrs, [:usd_amount, :currency, :status, :type])
    |> validate_required([:usd_amount, :currency, :status, :type])
    |> validate_number(:usd_amount, greater_than: 0)
    |> validate_length(:currency, is: 3)
    |> foreign_key_constraint(:instructor_id)
    |> foreign_key_constraint(:course_id)
    |> unique_constraint(:provider_payment_id)
  end

  # def create_pending_payment_for_student(course, attrs) do
  #   student = Backend.Repo.preload(student, :user)

  #   create_changeset(course, %{
  #     usd_amount: course.price,
  #     currency: student.currency,
  #     status: :pending,
  #     type: :course_payment_from_student
  #   })
  # end

  # def create_pending_payment_for_service_fee(course) do
  #   create_changeset(course, %{
  #     usd_amount: course.service_fee,
  #     currency: course.currency,
  #     status: :pending,
  #     type: :service_fee
  #   })
  # end
end
