defmodule YourApp.Repo.Migrations.AddInstructorCourseLessonVideosTable do
  use Ecto.Migration

  def change do
    create table(:instructor_course_lesson_videos, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :description, :text, default: ""
      add :video_url, :string, null: false

      add :lesson_id,
          references(:instructor_course_lessons, type: :binary_id, on_delete: :delete_all)

      add :module_id,
          references(:instructor_course_modules, type: :binary_id, on_delete: :delete_all)

      timestamps()
    end
  end
end
