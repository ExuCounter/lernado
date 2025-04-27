defmodule Backend.AWS.MultipartUpload do
  require Logger

  @type part :: %{
          etag: String.t(),
          part_number: integer()
        }

  @type aws_error :: {:unexpected_response, any()} | term()

  def get_mime_type_from_path(path) do
    path
    |> Path.extname()
    |> String.trim_leading(".")
    |> MIME.type()
  end

  @spec init_upload(%{
          client: map(),
          bucket: String.t(),
          key: String.t()
        }) :: {:ok, String.t()} | {:error, aws_error()}
  defp init_upload(%{
         client: client,
         bucket: bucket,
         key: key
       }) do
    with {:ok, %{"InitiateMultipartUploadResult" => %{"UploadId" => upload_id}}, _} <-
           AWS.S3.create_multipart_upload(client, bucket, key, %{
             "ContentType" => get_mime_type_from_path(key)
           }) do
      {:ok, upload_id}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @spec complete_upload(%{
          client: map(),
          bucket: String.t(),
          key: String.t(),
          upload_id: String.t(),
          parts: list(part())
        }) :: {:ok, term()} | {:error, aws_error()}
  defp complete_upload(%{
         client: client,
         bucket: bucket,
         key: key,
         upload_id: upload_id,
         parts: parts
       }) do
    parts_input =
      Enum.map(parts, fn
        %{etag: etag, part_number: part_number} ->
          %{
            "ETag" => etag,
            "PartNumber" => part_number
          }
      end)

    input = %{"CompleteMultipartUpload" => %{"Part" => parts_input}, "UploadId" => upload_id}

    with {:ok, result, _xml_info} <- AWS.S3.complete_multipart_upload(client, bucket, key, input) do
      url = result["CompleteMultipartUploadResult"]["Location"]

      {:ok, url}
    else
      {:error, reason} ->
        Logger.error("Multipart upload failed for #{key}. Reason: #{reason}")

        abort_upload(%{
          client: client,
          bucket: bucket,
          key: key,
          upload_id: upload_id
        })
    end
  end

  @spec complete_upload(%{
          client: map(),
          bucket: String.t(),
          filename: String.t(),
          upload_id: String.t()
        }) :: {:ok, term()} | {:error, aws_error()}
  defp abort_upload(%{
         client: client,
         bucket: bucket,
         key: key,
         upload_id: upload_id
       }) do
    input = %{"uploadId" => upload_id, "Key" => key}

    with {:ok, _output, _xml_info} <- AWS.S3.abort_multipart_upload(client, bucket, key, input) do
      Logger.info("Multipart upload aborted for #{key}.")
      {:ok, :aborted}
    else
      {:error, reason} ->
        Logger.error("Multipart upload abort failed for #{key}.")
        {:error, reason}
    end
  end

  @spec upload_part(%{
          client: map(),
          bucket: String.t(),
          filename: String.t(),
          upload_id: String.t(),
          key: String.t(),
          part_number: pos_integer(),
          chunk: binary()
        }) :: {:ok, list(part())} | {:error, aws_error()}
  defp upload_part(%{
         client: client,
         bucket: bucket,
         key: key,
         part_number: part_number,
         chunk: chunk,
         upload_id: upload_id
       }) do
    with {:ok, _output, %{headers: headers, status_code: 200}} <-
           AWS.S3.upload_part(client, bucket, key, %{
             "Body" => chunk,
             "PartNumber" => part_number,
             "UploadId" => upload_id
           }) do
      {_, etag} = Enum.find(headers, fn {header, _} -> header == "ETag" end)

      Logger.info("Multipart upload key: #{key}. Part #{part_number} completed successfully.")

      {:ok,
       %{
         etag: etag,
         part_number: part_number
       }}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec upload_part(%{
          client: map(),
          bucket: String.t(),
          filename: String.t(),
          upload_id: String.t(),
          key: String.t(),
          part_number: pos_integer(),
          chunk: binary()
        }) :: {:ok, list(part())} | {:error, aws_error()}
  defp upload_part_retry(
         %{
           client: client,
           bucket: bucket,
           key: key,
           part_number: part_number,
           chunk: chunk,
           upload_id: upload_id
         },
         opts \\ []
       ) do
    max_attempts = Keyword.get(opts, :max_attempts, 5)

    Enum.reduce_while(1..max_attempts, nil, fn attempt, _ ->
      case upload_part(%{
             client: client,
             bucket: bucket,
             key: key,
             part_number: part_number,
             chunk: chunk,
             upload_id: upload_id
           }) do
        {:ok, result} ->
          {:halt, {:ok, result}}

        {:error, reason} when attempt < max_attempts ->
          Logger.info(
            "Multipart upload key: #{key}. Part #{part_number} failed (#{reason}), retrying attempt #{attempt + 1}..."
          )

          # small delay to avoid overwhelming the server
          :timer.sleep(500)
          {:cont, nil}

        {:error, reason} ->
          {:halt, {:error, reason}}
      end
    end)
  end

  # 5 MB
  @chunk_size 5 * 1024 * 1024

  defp has_invalid_parts?(parts) do
    Enum.any?(parts, fn
      {:error, _} -> true
      _ -> false
    end)
  end

  # 120 seconds
  @upload_timeout 120 * 1000

  @spec upload_part(%{
          client: map(),
          bucket: String.t(),
          path: String.t(),
          key: String.t(),
          upload_id: String.t()
        }) :: {:ok, list(part())} | {:error, aws_error()}
  defp upload_parts(%{
         client: client,
         bucket: bucket,
         path: path,
         key: key,
         upload_id: upload_id
       }) do
    parts =
      path
      |> File.stream!(@chunk_size)
      |> Stream.with_index(1)
      |> Task.async_stream(
        fn {chunk, index} ->
          upload_part_retry(%{
            client: client,
            bucket: bucket,
            key: key,
            part_number: index,
            chunk: chunk,
            upload_id: upload_id
          })
        end,
        timeout: @upload_timeout
      )
      |> Enum.map(fn
        {:ok, {:ok, result}} -> result
        {:exit, reason} -> {:error, reason}
      end)

    if has_invalid_parts?(parts) do
      Logger.error("Multipart upload failed for #{key}.")

      abort_upload(%{
        client: client,
        bucket: bucket,
        key: key,
        upload_id: upload_id
      })
    else
      {:ok, parts}
    end
  end

  @spec upload_part(%{
          client: map(),
          bucket: String.t(),
          path: String.t(),
          key: String.t()
        }) :: {:ok, term()} | {:error, aws_error()}
  def upload(%{
        client: client,
        bucket: bucket,
        path: path,
        key: key
      }) do
    with {:ok, upload_id} <-
           init_upload(%{
             client: client,
             bucket: bucket,
             key: key
           }),
         {:ok, parts} <-
           upload_parts(%{
             client: client,
             bucket: bucket,
             upload_id: upload_id,
             path: path,
             key: key
           }) do
      complete_upload(%{
        client: client,
        bucket: bucket,
        upload_id: upload_id,
        parts: parts,
        key: key
      })
    end
  end
end
