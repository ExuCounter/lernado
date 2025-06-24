defmodule Backend.Students do
  def create_student(user) do
    user
    |> Backend.Students.Schema.Student.create_changeset()
    |> Backend.Repo.insert()
  end

  def create_student!(user) do
    user
    |> Backend.Students.Schema.Student.create_changeset()
    |> Backend.Repo.insert!()
  end

  def create_enrollment(student, course) do
    student
    |> Backend.Students.Schema.Enrollment.create_changeset(course)
    |> Backend.Repo.insert()
  end

  # def create_payment(student, course, attrs) do
  #   student
  #   |> Backend.Students.Schema.StudentPayment.create_changeset(course, attrs)
  #   |> Backend.Repo.insert()
  # end
end
