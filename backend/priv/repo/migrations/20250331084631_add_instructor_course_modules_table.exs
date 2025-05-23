defmodule Backend.Repo.Migrations.AddInstructorCourseModulesTable do
  use Ecto.Migration

  def change do
    create table(:course_modules, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :title, :string, null: false
      add :description, :text, default: "", null: false
      add :order_index, :integer, null: false
      add :course_id, references(:courses, type: :binary_id, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:course_modules, [:title, :course_id])
    create unique_index(:course_modules, [:order_index, :course_id])

    create constraint(:course_modules, :order_greater_than_zero, check: "order_index >= 0")
  end
end
