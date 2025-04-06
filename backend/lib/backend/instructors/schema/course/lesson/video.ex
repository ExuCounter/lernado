defmodule Backend.Instructors.Schema.Course.Lesson.Video do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :description, :video_url, :inserted_at, :updated_at]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "instructor_course_lesson_videos" do
    field :description, :string
    field :video_url, :string

    belongs_to :lesson, Backend.Instructors.Schema.Course.Lesson, type: :binary_id
    belongs_to :module, Backend.Instructors.Schema.Course.Module, type: :binary_id

    timestamps()
  end

  def create_changeset(lesson, attrs) do
    %__MODULE__{
      lesson_id: lesson.id,
      description: ""
    }
    |> cast(attrs, [:video_url, :description])
    |> validate_required([:video_url])
  end

  def update_changeset(video, attrs) do
    video
    |> cast(attrs, [:video_url, :description])
    |> validate_required([:video_url])
  end

  def get_by_lesson_id(lesson_id) do
    Backend.Repo.get_by(__MODULE__, lesson_id: lesson_id)
  end
end
