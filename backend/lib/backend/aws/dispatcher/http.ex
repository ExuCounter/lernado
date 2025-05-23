defmodule Backend.AWS.Dispatcher.HTTP do
  require Logger
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

  def multipart_upload(bucket, key, path) do
    client = client()

    {time, result} =
      :timer.tc(fn ->
        Backend.AWS.MultipartUpload.upload(%{
          client: client,
          bucket: bucket,
          key: key,
          path: path
        })
      end)

    Logger.info("Upload completed in #{time / 1_000} ms")

    result
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

  defp create_bucket(bucket) do
    client = client()
    region = config(:region)

    input = %{
      "CreateBucketConfiguration" => %{
        "LocationConstraint" => [region]
      }
    }

    case AWS.S3.create_bucket(client, bucket, input) do
      {:ok, _, _} ->
        {:ok, bucket}

      {:error, error} ->
        {:error, error}
    end
  end

  defp check_if_bucket_exists?(bucket) do
    client = client()
    input = %{}

    case AWS.S3.head_bucket(client, bucket, input) do
      {:ok, _, _} ->
        true

      {:error, _} ->
        false
    end
  end

  defp check_if_object_exists?(bucket, key) do
    client = client()
    input = %{}

    case AWS.S3.head_object(client, bucket, key, input) do
      {:ok, _, _} ->
        true

      {:error, _} ->
        nil
    end
  end

  def create_bucket_if_not_exists(bucket) do
    if check_if_bucket_exists?(bucket) do
      {:ok, :already_exists}
    else
      create_bucket(bucket)
    end
  end

  def delete_object(bucket, key) do
    client = client()
    input = %{}

    if check_if_object_exists?(bucket, key) do
      case AWS.S3.delete_object(client, bucket, key, input) do
        {:ok, _, _} ->
          {:ok, :deleted}

        {:error, error} ->
          {:error, error}
      end
    else
      {:error, :not_found}
    end
  end
end
