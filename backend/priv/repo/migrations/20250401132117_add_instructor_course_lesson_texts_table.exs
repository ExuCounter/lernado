defmodule YourApp.Repo.Migrations.AddInstructorCourseLessonTextsTable do
  use Ecto.Migration

  def change do
    create table(:instructor_course_lesson_texts, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :content, :text

      add :lesson_id,
          references(:instructor_course_lessons, type: :binary_id, on_delete: :delete_all)

      add :module_id,
          references(:instructor_course_modules, type: :binary_id, on_delete: :delete_all)

      timestamps()
    end
  end
end
