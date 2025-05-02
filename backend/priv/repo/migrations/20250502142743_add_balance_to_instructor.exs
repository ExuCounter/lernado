defmodule Backend.Repo.Migrations.AddBalanceToInstructor do
  use Ecto.Migration

  def change do
    alter table(:instructors) do
      add :usd_balance, :decimal, precision: 10, scale: 2, default: 0.0
    end
  end
end
