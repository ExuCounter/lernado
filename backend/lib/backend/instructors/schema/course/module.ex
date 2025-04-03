defmodule Backend.Instructors.Schema.Course.Module do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [:id, :title, :description, :order_index, :course, :inserted_at, :updated_at]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "instructor_course_modules" do
    field :title, :string
    field :description, :string
    field :order_index, :integer

    belongs_to :course, Backend.Instructors.Schema.Course, type: :binary_id

    timestamps()
  end

  def create_changeset(course, attrs) do
    order_index = Backend.Instructors.get_next_course_module_order_index(course)

    %__MODULE__{
      course_id: course.id,
      description: "",
      order_index: order_index
    }
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :order_index])
    |> unique_constraint([:order_index, :course_id])
    |> unique_constraint([:title, :course_id])
    |> foreign_key_constraint(:course_id)
    |> validate_length(:title, min: 3)
  end

  def update_changeset(module, attrs) do
    module
    |> cast(attrs, [:title, :description])
    |> validate_required([:title])
    |> unique_constraint([:order_index, :course_id])
    |> unique_constraint([:title, :course_id])
    |> foreign_key_constraint(:course_id)
    |> validate_length(:title, min: 3)
  end
end
