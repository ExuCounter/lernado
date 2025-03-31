defmodule Backend.Instructors.Schema.Course.Module do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [:id, :title, :description, :order, :course, :inserted_at, :updated_at]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "instructor_course_modules" do
    field :title, :string
    field :description, :string
    field :order, :integer

    belongs_to :course, Backend.Instructors.Schema.Course, type: :binary_id

    timestamps()
  end

  def create_changeset(course, attrs) do
    order = Backend.Instructors.Queries.get_next_course_module_order(course)

    %__MODULE__{
      course_id: course.id,
      description: "",
      order: order
    }
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :order])
    |> unique_constraint(:title)
    |> foreign_key_constraint(:course_id)
    |> validate_length(:title, min: 3)
  end

  def update_changeset(module, attrs) do
    module
    |> cast(attrs, [:title, :description])
    |> validate_required([:title])
    |> unique_constraint(:title)
    |> foreign_key_constraint(:course_id)
    |> validate_length(:title, min: 3)
  end
end
