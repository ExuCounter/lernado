defmodule Backend.AWS.MultipartUpload do
  require Logger

  defp init_upload(%{
         client: client,
         bucket: bucket,
         key: key
       }) do
    {:ok, %{"InitiateMultipartUploadResult" => %{"UploadId" => upload_id}}, _} =
      AWS.S3.create_multipart_upload(client, bucket, key, %{})

    upload_id
  end

  defp complete_upload(%{
         client: client,
         bucket: bucket,
         key: key,
         upload_id: upload_id,
         parts: parts
       }) do
    input = %{"CompleteMultipartUpload" => %{"Part" => parts}, "UploadId" => upload_id}

    AWS.S3.complete_multipart_upload(client, bucket, key, input)
  end

  defp abort_upload(%{
         client: client,
         bucket: bucket,
         key: key,
         upload_id: upload_id
       }) do
    input = %{"uploadId" => upload_id, "Key" => key}

    AWS.S3.abort_multipart_upload(client, bucket, key, input)

    Logger.info("Multipart upload aborted for #{key}.")

    {:error, :aborted}
  end

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

  def upload_part_retry(
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

  def upload(%{
        client: client,
        bucket: bucket,
        filename: filename,
        key: key
      }) do
    upload_id =
      init_upload(%{
        client: client,
        bucket: bucket,
        filename: filename,
        key: key
      })

    stream =
      filename
      |> File.stream!(@chunk_size)
      |> Stream.with_index(1)
      |> Task.async_stream(
        fn {chunk, index} ->
          result =
            upload_part(%{
              client: client,
              bucket: bucket,
              key: key,
              part_number: index,
              chunk: chunk,
              upload_id: upload_id
            })

          Logger.info("Multipart upload key: #{key}. Part #{index} completed successfully.")

          result
        end,
        timeout: 120 * 1000
      )

    parts =
      Enum.map(stream, fn
        {:ok, result} -> result
        {:exit, reason} -> {:error, reason}
      end)

    has_upload_errors? =
      Enum.any?(parts, fn
        {:error, _} -> true
        _ -> false
      end)

    if has_upload_errors? do
      Logger.error("Multipart upload failed for #{key}. Aborting upload...")

      abort_upload(%{
        client: client,
        bucket: bucket,
        key: key,
        upload_id: upload_id
      })
    else
      parts =
        Enum.map(parts, fn {:ok, %{etag: etag, part_number: part_number}} ->
          %{
            "ETag" => etag,
            "PartNumber" => part_number
          }
        end)

      complete_upload(%{
        client: client,
        bucket: bucket,
        key: key,
        upload_id: upload_id,
        parts: parts
      })
    end
  end
end
