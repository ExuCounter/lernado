defmodule Backend.Instructors.Schema.Instructor do
  use Backend, :schema

  @derive {Jason.Encoder, only: [:id, :user, :inserted_at, :updated_at]}
  schema "instructors" do
    belongs_to :user, Backend.Users.Schema.User
    has_many :projects, Backend.Instructors.Schema.Project

    has_many :payment_integrations, Backend.Instructors.Schema.PaymentIntegration

    timestamps()
  end

  def create_changeset(user, attrs) do
    %__MODULE__{
      user_id: user.id
    }
    |> cast(attrs, [])
    |> validate_required([:user_id])
    |> unique_constraint(:user_id)
    |> foreign_key_constraint(:user_id)
  end
end
