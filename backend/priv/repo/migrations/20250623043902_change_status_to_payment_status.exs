defmodule Backend.Repo.Migrations.ChangeStatusToPaymentStatus do
  use Ecto.Migration

  def up do
    alter table(:instructor_payments) do
      add :payment_status, :instructor_payment_status, null: false
      add :payment_type, :instructor_payment_type, null: false
    end

    execute "UPDATE instructor_payments SET payment_status = status"
    execute "UPDATE instructor_payments SET payment_type = type"

    alter table(:instructor_payments) do
      remove :status
      remove :type
    end
  end

  def down do
    alter table(:instructor_payments) do
      add :status, :instructor_payment_status, null: false
      add :type, :instructor_payment_type, null: false
    end

    execute "UPDATE instructor_payments SET status = payment_status"
    execute "UPDATE instructor_payments SET type = payment_type"

    alter table(:instructor_payments) do
      remove :payment_status
      remove :payment_type
    end
  end
end
