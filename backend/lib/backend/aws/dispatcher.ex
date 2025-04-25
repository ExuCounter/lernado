defmodule Backend.AWS.Dispatcher do
  @type aws_error :: {:unexpected_response, any()} | term()

  @callback multipart_upload(bucket :: String.t(), key :: String.t(), filename :: String.t()) ::
              {:ok, term()} | {:error, aws_error()}
  @callback list_objects(bucket :: String.t()) :: any()
  @callback create_bucket_if_not_exists(bucket :: String.t()) :: any()
end
