defmodule Backend.Repo.Migrations.CreateStudentPaymentsTable do
  use Ecto.Migration
  import Backend.MigrationHelpers

  def change do
    create table(:students, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :user_id, references(:users, type: :binary_id), null: false

      timestamps()
    end

    create unique_index(:students, [:user_id])

    create table(:student_enrollments, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :student_id, references(:students, type: :binary_id), null: false
      add :course_id, references(:courses, type: :binary_id), null: false

      timestamps()
    end

    create unique_index(:student_enrollments, [:student_id, :course_id])

    create_enum(:student_payment_status, ["pending", "succeeded", "failed"])

    create table(:student_payments, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :amount, :decimal, null: false
      add :currency, :string, null: false
      add :payment_status, :student_payment_status, null: false
      add :student_id, references(:students, type: :binary_id), null: false
      add :instructor_payment_id, references(:instructor_payments, type: :binary_id), null: false
      add :course_id, references(:courses, type: :binary_id), null: false

      timestamps()
    end
  end
end
