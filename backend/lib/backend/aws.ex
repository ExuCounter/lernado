defmodule Backend.AWS do
  @behaviour Backend.AWS.Dispatcher

  defp config(key) do
    Keyword.fetch!(Application.get_env(:backend, :aws), key)
  end

  def multipart_upload(bucket, key, filename) do
    config(:dispatcher).multipart_upload(bucket, key, filename)
  end

  def list_objects(bucket) do
    config(:dispatcher).list_objects(bucket)
  end

  def create_bucket_if_not_exists(bucket) do
    config(:dispatcher).create_bucket_if_not_exists(bucket)
  end
end
