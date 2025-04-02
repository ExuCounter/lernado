defmodule Backend.Repo.Migrations.AddInstructorCourseModulesTable do
  use Ecto.Migration

  def change do
    create table(:instructor_course_modules, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :title, :string, null: false
      add :description, :string, default: "", null: false
      add :order_index, :integer, null: false
      add :course_id, references(:instructor_courses, type: :binary_id, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:instructor_course_modules, [:title, :course_id])
    create unique_index(:instructor_course_modules, [:order_index, :course_id])

    create constraint(:instructor_course_modules, :order_greater_than_zero,
             check: "order_index >= 0"
           )
  end
end
