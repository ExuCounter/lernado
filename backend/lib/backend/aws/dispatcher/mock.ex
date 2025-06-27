defmodule Backend.AWS.Dispatcher.Mock do
  @behaviour Backend.AWS.Dispatcher

  def multipart_upload(bucket, key, filename) do
    file_dir = get_file_dir(bucket, key)
    file_path = get_file_path(bucket, key)

    File.mkdir_p!(file_dir)
    File.copy!(filename, file_path)

    {:ok, file_path}
  end

  def list_objects(bucket) do
    bucket_dir = get_bucket_dir(bucket)

    list_files_recursively(bucket_dir) |> List.flatten()
  end

  def create_bucket_if_not_exists(bucket) do
    {:ok, bucket}
  end

  def delete_object(bucket, key) do
    file_path = get_file_path(bucket, key)

    File.rm!(file_path)

    {:ok, :deleted}
  end

  defp get_bucket_dir(bucket) do
    priv_dir = :code.priv_dir(:backend)
    Path.join([priv_dir, "static", "uploads", bucket])
  end

  defp get_file_dir(bucket, key) do
    bucket_dir = get_bucket_dir(bucket)
    key_dir = Path.dirname(key)

    Path.join([bucket_dir, key_dir])
  end

  defp get_file_path(bucket, key) do
    bucket_dir = get_bucket_dir(bucket)
    Path.join([bucket_dir, key])
  end

  defp list_files_recursively(current_dir) do
    files = File.ls!(current_dir)

    files
    |> Enum.map(fn file ->
      full_path = Path.join(current_dir, file)

      case File.stat!(full_path, time: :posix) do
        %File.Stat{type: :directory} ->
          list_files_recursively(full_path)

        stats ->
          datetime = DateTime.from_unix!(stats.mtime, :second)
          iso8601 = DateTime.to_iso8601(datetime)

          %{
            key: full_path,
            last_modified: iso8601
          }
      end
    end)
  end
end
