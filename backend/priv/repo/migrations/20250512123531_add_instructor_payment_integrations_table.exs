defmodule Backend.Repo.Migrations.AddInstructorPaymentIntegrationsTable do
  use Ecto.Migration
  import Backend.MigrationHelpers

  def change do
    create_enum(:payments_provider_type, ["liqpay"])

    create table(:instructor_payment_integrations, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :provider, :payments_provider_type, null: false

      add :instructor_id, references(:instructors, type: :uuid, on_delete: :nothing)
      add :credentials, :map, null: false

      timestamps()
    end
  end
end
