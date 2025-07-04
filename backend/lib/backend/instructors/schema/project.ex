defmodule Backend.Instructors.Schema.Project do
  use Backend, :schema

  @derive {Jason.Encoder, only: [:id, :name, :inserted_at, :updated_at]}
  schema "projects" do
    field :name, :string

    belongs_to :instructor, Backend.Instructors.Schema.Instructor
    has_many :courses, Backend.Instructors.Schema.Course, foreign_key: :project_id

    timestamps()
  end

  def create_changeset(instructor, attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name])
    |> put_assoc(:instructor, instructor)
    |> validate_required([:name])
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
