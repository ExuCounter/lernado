defmodule Backend.AWS.Dispatcher do
  @callback multipart_upload(bucket :: String.t(), key :: String.t(), filename :: String.t()) ::
              any()
  @callback list_objects(bucket :: String.t()) :: any()
  @callback create_bucket_if_not_exists(bucket :: String.t()) :: any()
end
