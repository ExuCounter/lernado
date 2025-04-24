defmodule Backend.AWS.BucketsManager do
  use GenServer
  require Logger

  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def init(%{create_if_not_exists: create_if_not_exists} = initial_state) do
    for bucket <- create_if_not_exists do
      case Backend.AWS.create_bucket_if_not_exists(bucket) do
        {:ok, _} ->
          Logger.info("Bucket #{bucket} created or already exists.")
          :ok

        {:error, reason} ->
          Logger.error("Failed to create bucket #{bucket}: #{inspect(reason)}")
          :init.stop()
      end
    end

    {:ok, initial_state}
  end
end
