defmodule Backend.Instructors.Schema.Course.Lesson.Text do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :content, :lesson, :inserted_at, :updated_at]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "instructor_course_lesson_texts" do
    field :content, :string

    belongs_to :lesson, Backend.Instructors.Schema.Course.Lesson, type: :binary_id
    belongs_to :module, Backend.Instructors.Schema.Course.Module, type: :binary_id

    timestamps()
  end

  def create_changeset(lesson, attrs) do
    %__MODULE__{
      lesson_id: lesson.id
    }
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
