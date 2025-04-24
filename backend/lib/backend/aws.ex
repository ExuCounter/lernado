defmodule Backend.AWS do
  @behaviour Backend.AWS.Dispatcher

  defp config(key) do
    Keyword.fetch!(Application.fetch_env!(:backend, :aws), key)
  end 

  def multipart_upload(bucket, key, filename) do
    config(:dispatcher).multipart_upload(bucket, key, filename)
  end

  def list_objects(bucket) do
    config(:dispatcher).list_objects(bucket)
  end
end
