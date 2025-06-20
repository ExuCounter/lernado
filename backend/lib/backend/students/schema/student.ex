defmodule Backend.Students.Schema.Student do
  use Backend, :schema

  schema "students" do
    belongs_to :user, Backend.Users.Schema.User
    has_many :payments, Backend.Students.Schema.Payment
    has_many :enrollments, Backend.Students.Schema.Enrollment
    has_many :courses, through: [:enrollments, :course]

    timestamps()
  end

  def create_changeset(user) do
    %__MODULE__{}
    |> cast(%{}, [])
    |> put_assoc(:user, user)
  end
end
