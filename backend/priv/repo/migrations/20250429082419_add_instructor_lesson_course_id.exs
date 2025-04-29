defmodule Backend.Repo.Migrations.AddInstructorLessonCourseId do
  use Ecto.Migration

  def change do
    alter table(:course_lessons) do
      add :course_id, references(:courses, type: :uuid, on_delete: :delete_all)
    end
  end
end
