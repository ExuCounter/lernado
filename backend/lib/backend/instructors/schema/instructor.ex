defmodule Backend.Instructors.Schema.Instructor do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :user]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "instructors" do
    belongs_to :user, Backend.Users.Schema.User, type: :binary_id
    has_many :projects, Backend.Instructors.Schema.Project

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
