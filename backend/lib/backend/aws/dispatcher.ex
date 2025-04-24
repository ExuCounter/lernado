defmodule Backend.AWS.Dispatcher do
  @callback multipart_upload(bucket :: String.t(), key :: String.t(), filename :: String.t()) ::
              any()
  @callback list_objects(bucket :: String.t()) :: any()
end
