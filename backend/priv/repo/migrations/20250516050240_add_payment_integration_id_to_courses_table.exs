defmodule Backend.Repo.Migrations.AddPaymentIntegrationIdToCoursesTable do
  use Ecto.Migration

  def change do
    alter table(:courses) do
      add :payment_integration_id,
          references(:instructor_payment_integrations, type: :uuid, on_delete: :nothing)
    end
  end
end
