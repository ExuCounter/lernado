defmodule Backend.Repo.Migrations.AddUserTable do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :first_name, :string
      add :last_name, :string
      add :email, :string, null: false
      add :password_hash, :string
      add :preferred_currency, :string, size: 3

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
