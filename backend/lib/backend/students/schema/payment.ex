defmodule Backend.Students.Schema.StudentPayment do
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

    belongs_to :instructor_payment, Backend.Instructors.Schema.InstructorPayment

    timestamps()
  end

  def create_changeset(student, course, attrs) do
    %__MODULE__{}
    |> cast(attrs, [:amount, :currency, :payment_status])
    |> put_assoc(:student, student)
    |> put_assoc(:course, course)
    |> validate_required([:amount, :currency, :payment_status])
  end

  def link_instructor_payment_changeset(student_payment, instructor_payment) do
    student_payment
    |> cast(%{}, [])
    |> put_assoc(:instructor_payment, instructor_payment)
  end
end
