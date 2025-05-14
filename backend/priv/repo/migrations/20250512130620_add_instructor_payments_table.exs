defmodule Backend.Repo.Migrations.AddInstructorPaymentsTable do
  use Ecto.Migration
  import Backend.MigrationHelpers

  def change do
    create_enum(:instructor_payment_type, ["course_payment_from_student"])
    create_enum(:instructor_payment_status, ["pending", "succeeded", "failed"])

    create table(:instructor_payments, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :external_id, :string
      add :status, :instructor_payment_status, null: false
      add :amount, :decimal, precision: 10, scale: 2, null: false
      add :currency, :string, null: false, size: 3
      add :type, :instructor_payment_type, null: false

      add :instructor_id, references(:instructors, type: :uuid, on_delete: :nothing)
      add :course_id, references(:courses, type: :uuid, on_delete: :nothing)

      add :payment_integration_id,
          references(:instructor_payment_integrations, type: :uuid, on_delete: :nothing)

      timestamps()
    end

    create constraint(:instructor_payments, :amount_greater_than_zero, check: "amount > 0")

    create constraint(:instructor_payments, :external_id_is_not_null,
             check: "status != 'succeeded' OR external_id is not null"
           )
  end
end
