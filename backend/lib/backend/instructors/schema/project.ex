defmodule Backend.Instructors.Schema.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :instructor, :name]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "instructor_projects" do
    field :name, :string

    belongs_to :instructor, Backend.Instructors.Schema.Instructor
    has_many :courses, Backend.Instructors.Schema.Course, foreign_key: :project_id

    timestamps()
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name, :instructor_id])
    |> validate_required([:name, :instructor_id])
    |> unique_constraint(:name)
    |> validate_length(:name, min: 6)
  end

  def update_changeset(project, attrs) do
    project
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> validate_length(:name, min: 6)
  end
end
