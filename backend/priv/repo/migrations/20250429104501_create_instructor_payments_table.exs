defmodule Backend.Repo.Migrations.CreateInstructorPaymentsTable do
  use Ecto.Migration
  import Backend.MigrationHelpers

  def change do
    create_enum(:instructor_payment_type, ["course_payment_from_student", "service_fee"])
    create_enum(:instructor_payment_status, ["pending", "succeeded", "failed"])

    create table(:instructor_payments, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :provider, :string, null: false
      add :provider_payment_id, :string, null: false
      add :status, :instructor_payment_status, null: false
      add :usd_amount, :decimal, precision: 10, scale: 2, null: false
      add :currency, :string, null: false, size: 3
      add :type, :instructor_payment_type, null: false

      add :instructor_id, references(:instructors, type: :uuid, on_delete: :nothing)
      add :course_id, references(:courses, type: :uuid, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:instructor_payments, [:provider_payment_id])
    create constraint(:instructor_payments, :amount_greater_than_zero, check: "usd_amount > 0")
  end
end
