defmodule Backend.Instructors.Schema.Course do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :name,
             :description,
             :status,
             :price,
             :currency,
             :project,
             :inserted_at,
             :updated_at
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "instructor_courses" do
    field :name, :string
    field :description, :string
    field :status, Backend.Instructors.InstructorProjectStatus
    field :price, :decimal
    field :currency, :string

    belongs_to :project, Backend.Instructors.Schema.Project, type: :binary_id

    timestamps()
  end

  def create_changeset(project, attrs) do
    %__MODULE__{
      project_id: project.id,
      price: 0.0,
      currency: "USD",
      description: "",
      status: "draft"
    }
    |> cast(attrs, [:name, :description, :price, :currency])
    |> validate_required([:name, :status, :price, :currency, :project_id])
    |> unique_constraint(:name)
    |> foreign_key_constraint(:project_id)
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_length(:name, min: 6)
  end

  def update_changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :description, :price, :currency])
    |> validate_required([:name, :price, :currency])
    |> unique_constraint(:name)
    |> validate_length(:name, min: 6)
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:project_id)
    |> validate_length(:currency, is: 3)
  end
end
