defmodule Backend.Instructors.Schema.Course.Lesson.Text do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :content, :inserted_at, :updated_at]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "course_lesson_texts" do
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
  end

  def update_changeset(lesson, attrs) do
    lesson |> cast(attrs, [:content])
  end

  def get_by_lesson_id(lesson_id) do
    Backend.Repo.get_by(__MODULE__, lesson_id: lesson_id)
  end
end
