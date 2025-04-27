defmodule Backend.AWS.Courses do
  defp config(key) do
    Keyword.fetch!(Application.fetch_env!(:backend, :aws), key)
  end

  def multipart_upload(key, path) do
    bucket = config(:courses_bucket)
    Backend.AWS.multipart_upload(bucket, key, path)
  end

  def list do
    bucket = config(:courses_bucket)
    Backend.AWS.list_objects(bucket)
  end
end
