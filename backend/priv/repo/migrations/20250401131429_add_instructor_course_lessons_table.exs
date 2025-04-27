defmodule YourApp.Repo.Migrations.AddInstructorCourseLessonsTable do
  use Ecto.Migration
  import Backend.MigrationHelpers

  def change do
    create_enum(:course_lesson_type, ["text", "video"])

    create table(:course_lessons, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :type, :course_lesson_type, null: false, default: "text"
      add :title, :string, null: false
      add :order_index, :integer, null: false

      add :module_id,
          references(:course_modules, type: :binary_id, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:course_lessons, [:title, :module_id])
    create unique_index(:course_lessons, [:order_index, :module_id])

    create constraint(:course_lessons, :order_greater_than_zero,
             check: "order_index >= 0"
           )
  end
end
