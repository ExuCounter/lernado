defmodule Backend.AWS.BucketsManager do
  use GenServer
  require Logger

  def config(key) do
    Keyword.fetch(Application.get_env(:backend, :aws), key)
  end

  def start_link(_initial_state) do
    buckets = []

    buckets =
      case config(:courses_bucket) do
        {:ok, bucket} ->
          buckets ++ [bucket]

        :error ->
          buckets
      end

    GenServer.start_link(__MODULE__, buckets, name: __MODULE__)
  end

  def init(buckets) do
    for bucket <- buckets do
      case Backend.AWS.create_bucket_if_not_exists(bucket) do
        {:ok, :already_exists} ->
          :ok

        {:ok, bucket} ->
          Logger.info("AWS Bucket \"#{bucket}\" created.")
          :ok

        {:error, _reason} ->
          nil
          # Logger.error("Failed to create bucket #{bucket}: #{inspect(reason)}")
      end
    end

    {:ok, buckets}
  end
end
