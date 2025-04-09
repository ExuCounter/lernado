defmodule Backend.Repo.Migrations.AddInstructorCoursePublicLinkField do
  use Ecto.Migration

  def change do
    alter table(:instructor_courses) do
      add :public_path, :string
    end

    create unique_index(:instructor_courses, [:public_path])

    create constraint(:instructor_courses, :public_path_not_empty_when_published,
             check: "status != 'published' OR (public_path IS NOT NULL AND public_path != '')"
           )
  end
end
