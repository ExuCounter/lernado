defmodule Backend.Students do
  def create_student(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create_student, Backend.Students.Schema.Student.create_changeset(user))
    |> Backend.Repo.transaction()
    |> case do
      {:ok, %{create_student: student}} -> {:ok, %{user | student: student}}
      {:error, _operation, changeset, _changes} -> {:error, changeset}
    end
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
