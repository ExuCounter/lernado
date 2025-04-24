defmodule Backend.AWS.Dispatcher.HTTP do
  @behaviour Backend.AWS.Dispatcher

  defp config(key) do
    Keyword.fetch!(Application.fetch_env!(:backend, :aws), key)
  end

  defp client do
    AWS.Client.create(
      config(:access_key_id),
      config(:secret_access_key),
      config(:session_token),
      config(:region)
    )
  end

  def multipart_upload(bucket, key, filename) do
    client = client()

    Backend.AWS.MultipartUpload.upload(%{
      client: client,
      bucket: bucket,
      key: key,
      filename: filename
    })
  end

  defp map_object(%{
         "Key" => key,
         "LastModified" => last_modified
       }) do
    %{
      key: key,
      last_modified: last_modified
    }
  end

  def list_objects(bucket) do
    client = client()

    {:ok, %{"ListBucketResult" => %{"Contents" => contents}}, _} =
      AWS.S3.list_objects(client, bucket)

    if is_list(contents) do
      Enum.map(contents, &map_object/1)
    else
      [map_object(contents)]
    end
  end
end
