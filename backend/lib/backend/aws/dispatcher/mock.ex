defmodule Backend.AWS.Dispatcher.Mock do
  @behaviour Backend.AWS.Dispatcher

  def multipart_upload(_bucket, _key, _filename) do
    {:ok,
     %{
       "CompleteMultipartUploadResult" => %{
         "Bucket" => "my-bucket",
         "Key" => "file.bin",
         "Location" => "https://dummy.aws.location/file.bin"
       },
       "ServerSideEncryption" => "AES256"
     }}
  end

  def list_objects(_bucket) do
    [
      %{
        key: "file.bin",
        last_modified: "2023-10-01T00:00:00Z"
      }
    ]
  end
end
