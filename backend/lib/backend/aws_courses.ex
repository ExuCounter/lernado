defmodule Backend.AWS.Courses do
  defp config(key) do
    Keyword.fetch!(Application.fetch_env!(:backend, :aws), key)
  end

  @allowed_mime_video_types [
    "video/quicktime",
    "video/x-divx",
    "video/x-flv",
    "video/mpeg",
    "video/x-ms-wmv",
    "video/x-matroska",
    "video/mp2t",
    "video/mp4",
    "video/x-msvideo"
  ]

  @allowed_mime_audio_types [
    "audio/wav"
  ]

  @allowed_mime_types @allowed_mime_video_types ++ @allowed_mime_audio_types

  def key(course_id, filename) do
    "courses/#{course_id}/#{filename}"
  end

  def upload_file(course_id, path, filename) do
    bucket = config(:courses_bucket)
    key = key(course_id, filename)
    mime_type = MIME.from_path(filename)

    if mime_type in @allowed_mime_types do
      Backend.AWS.multipart_upload(bucket, key, path)
    else
      {:error,
       %{status: :bad_request, message: "Filetype: #{mime_type} is not allowed for upload"}}
    end
  end

  def list_files do
    bucket = config(:courses_bucket)
    Backend.AWS.list_objects(bucket)
  end

  def delete_file(course_id, filename) do
    bucket = config(:courses_bucket)
    key = key(course_id, filename)

    Backend.AWS.delete_object(bucket, key)
  end
end
