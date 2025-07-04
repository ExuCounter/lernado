defmodule Backend.Users.Schema.User do
  use Backend, :schema

  @derive {Jason.Encoder,
           only: [
             :id,
             :first_name,
             :last_name,
             :email,
             :preferred_currency,
             :inserted_at,
             :updated_at
           ]}
  schema "users" do
    field(:email, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:preferred_currency, :string)

    has_one(:instructor, Backend.Instructors.Schema.Instructor)
    has_one(:student, Backend.Students.Schema.Student)

    timestamps()
  end

  def hash_password(changeset) do
    case get_change(changeset, :password) do
      nil ->
        changeset

      password ->
        put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))
    end
  end

  def create_changeset(attrs) do
    %__MODULE__{
      preferred_currency: "USD"
    }
    |> cast(attrs, [:first_name, :last_name, :password, :email, :preferred_currency])
    |> hash_password()
    |> put_change(:password, nil)
    |> unique_constraint(:email)
    |> validate_required([:first_name, :last_name, :email, :password_hash, :preferred_currency])
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :preferred_currency])
    |> validate_required([:first_name, :last_name, :email, :preferred_currency])
    |> unique_constraint(:email)
  end
end
