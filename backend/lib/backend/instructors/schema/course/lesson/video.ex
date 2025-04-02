defmodule Backend.Instructors.Schema.Course.Lesson.Video do
  use Ecto.Schema

  @derive {Jason.Encoder,
           only: [:id, :description, :video_url, :lesson, :inserted_at, :updated_at]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "instructor_course_lesson_videos" do
    field :description, :string
    field :video_url, :string

    belongs_to :lesson, Backend.Instructors.Schema.Course.Lesson, type: :binary_id
    belongs_to :module, Backend.Instructors.Schema.Course.Module, type: :binary_id

    timestamps()
  end
end
