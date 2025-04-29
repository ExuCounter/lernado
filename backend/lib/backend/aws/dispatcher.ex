defmodule Backend.AWS.Dispatcher do
  @type aws_error :: {:unexpected_response, any()} | term()
  @type aws_object :: %{
          key: String.t(),
          last_modified: String.t()
        }

  @callback multipart_upload(bucket :: String.t(), key :: String.t(), filename :: String.t()) ::
              {:ok, term()} | {:error, aws_error()}
  @callback list_objects(bucket :: String.t()) :: list(aws_object()) | {:error, aws_error()}
  @callback create_bucket_if_not_exists(bucket :: String.t()) ::
              {:ok, String.t()} | {:error, aws_error()}
  @callback delete_object(bucket :: String.t(), key :: String.t()) ::
              {:ok, term()} | {:error, aws_error()}
end
