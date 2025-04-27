defmodule Backend.Repo.Migrations.AddInstructorTables do
  use Ecto.Migration
  import Backend.MigrationHelpers

  def change do
    # Create instructors table
    create table(:instructors, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:instructors, [:user_id])

    # Create projects table
    create table(:projects, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :instructor_id, references(:instructors, type: :uuid, on_delete: :delete_all)
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:projects, [:name])

    create_enum(:project_status, ["draft", "published", "archived"])

    # Create courses table
    create table(:courses, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :project_id, references(:projects, type: :uuid, on_delete: :delete_all)
      add :name, :string, null: false
      add :description, :text
      add :status, :project_status, null: false, default: "draft"
      add :price, :decimal
      add :currency, :string, size: 3

      timestamps()
    end

    create unique_index(:courses, [:name])

    # Add a check constraint for price and currency when status is published
    create constraint(:courses, :price_currency_not_null_when_published,
             check: "status != 'published' OR (price IS NOT NULL AND currency IS NOT NULL)"
           )
  end
end
