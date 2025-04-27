defmodule Backend.Instructors.Schema.Course.Lesson do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :title,
             :type,
             :order_index,
             :module,
             :video_details,
             :text_details,
             :inserted_at,
             :updated_at
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "course_lessons" do
    field :title, :string
    field :order_index, :integer
    field :type, Backend.Instructors.Course.Lesson.Type

    belongs_to :module, Backend.Instructors.Schema.Course.Module, type: :binary_id

    has_one :video_details, Backend.Instructors.Schema.Course.Lesson.Video,
      foreign_key: :lesson_id

    has_one :text_details, Backend.Instructors.Schema.Course.Lesson.Text, foreign_key: :lesson_id

    timestamps()
  end

  def create_changeset(module, attrs) do
    order_index = Backend.Instructors.get_next_course_lesson_order_index(module)

    %__MODULE__{
      module_id: module.id,
      order_index: order_index
    }
    |> cast(attrs, [:title, :type])
    |> validate_required([:title, :order_index, :type])
    |> foreign_key_constraint(:module_id)
    |> validate_length(:title, min: 3)
    |> validate_number(:order_index, greater_than_or_equal_to: 0)
    |> unique_constraint([:order_index, :module_id])
    |> unique_constraint([:title, :module_id])
  end

  def update_changeset(lesson, attrs) do
    lesson
    |> cast(attrs, [:title, :type])
    |> validate_required([:title, :type])
    |> validate_length(:title, min: 3)
    |> unique_constraint([:title, :module_id])
  end
end
