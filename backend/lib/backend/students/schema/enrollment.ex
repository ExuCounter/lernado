defmodule Backend.Students.Schema.Enrollment do
  use Backend, :schema

  schema "student_enrollments" do
    belongs_to :student, Backend.Students.Schema.Student
    belongs_to :course, Backend.Instructors.Schema.Course

    timestamps()
  end

  def create_changeset(student, course) do
    %__MODULE__{}
    |> cast(%{}, [])
    |> put_assoc(:student, student)
    |> put_assoc(:course, course)
  end
end
