defmodule YourApp.Repo.Migrations.AddInstructorCourseLessonsTable do
  use Ecto.Migration
  import Backend.MigrationHelpers

  def change do
    create_enum(:instructor_course_lesson_type, ["text", "video"])

    create table(:instructor_course_lessons, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :type, :instructor_course_lesson_type, null: false, default: "text"
      add :title, :string, null: false
      add :order_index, :integer, null: false

      add :module_id,
          references(:instructor_course_modules, type: :binary_id, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:instructor_course_lessons, [:title, :module_id])
    create unique_index(:instructor_course_lessons, [:order_index, :module_id])

    create constraint(:instructor_course_lessons, :order_greater_than_zero,
             check: "order_index >= 0"
           )
  end
end
