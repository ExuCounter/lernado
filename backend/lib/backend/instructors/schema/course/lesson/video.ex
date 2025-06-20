defmodule Backend.Instructors.Schema.Course.Lesson.Video do
  use Backend, :schema

  @derive {Jason.Encoder, only: [:id, :description, :video_url, :inserted_at, :updated_at]}
  schema "course_lesson_videos" do
    field :description, :string
    field :video_url, :string

    belongs_to :lesson, Backend.Instructors.Schema.Course.Lesson
    belongs_to :module, Backend.Instructors.Schema.Course.Module

    timestamps()
  end

  def create_changeset(lesson, attrs) do
    %__MODULE__{
      lesson_id: lesson.id,
      description: ""
    }
    |> cast(attrs, [:video_url, :description])
  end

  def update_changeset(video, attrs) do
    video
    |> cast(attrs, [:video_url, :description])
  end

  def get_by_lesson_id(lesson_id) do
    Backend.Repo.get_by(__MODULE__, lesson_id: lesson_id)
  end
end
