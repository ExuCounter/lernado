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

  def create_changeset(student, course, instructor_payment, attrs) do
    %__MODULE__{}
    |> cast(attrs, [:amount, :currency, :payment_status])
    |> put_assoc(:student, student)
    |> put_assoc(:course, course)
    |> put_assoc(:instructor_payment, instructor_payment)
    |> validate_required([:amount, :currency, :payment_status])
  end
end
