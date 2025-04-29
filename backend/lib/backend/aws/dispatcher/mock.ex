defmodule Backend.AWS.Dispatcher.Mock do
  @behaviour Backend.AWS.Dispatcher

  def multipart_upload(bucket, key, path) do
    path |> File.read!()

    Process.sleep(:rand.uniform(1_000))

    {:ok, "https://aws.amazon.com/#{bucket}/#{key}"}
  end

  def list_objects(_bucket) do
    [
      %{
        key: "file.bin",
        last_modified: "2025-04-01T00:00:00Z"
      }
    ]
  end

  def create_bucket_if_not_exists(bucket) do
    {:ok, bucket}
  end

  def delete_object(_bucket, _key) do
    {:ok, :deleted}
  end
end
