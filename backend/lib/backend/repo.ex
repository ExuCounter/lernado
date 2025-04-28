defmodule Backend.Repo do
  use Ecto.Repo,
    otp_app: :backend,
    adapter: Ecto.Adapters.Postgres

  defp humanize_struct_name(module) do
    module
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
    |> Phoenix.Naming.humanize()
  end

  defp module_from_query(%{from: %{source: {_, module}}}), do: module

  defp module_from_query(%{from: %{source: %{query: subquery} = source}}) when is_map(source) do
    module_from_query(subquery)
  end

  @doc """
  ## Examples

      iex> find_by_id(User, id)
      {:ok, %User{}}

      iex> find_by_id(UserProfile, unknown_id)
      {:error, %{message: "User profile is not found", status: :not_found}}

      iex> find_by_id(User, unknown_id, error_message: "Not found")
      {:error, %{message: "Not found", status: :not_found}}
  """
  def find_by_id(query, id, opts \\ []) do
    find_by(query, [id: id], opts)
  end

  def find_by(query, clauses, opts \\ []) do
    query = Ecto.Queryable.to_query(query)

    case get_by(query, clauses) do
      nil ->
        message =
          case {opts[:error_message], query} do
            {message, _query} when is_binary(message) ->
              message

            {nil, module} when is_atom(module) ->
              "#{humanize_struct_name(module)} not found"

            {nil, query} ->
              module = module_from_query(query)
              "#{humanize_struct_name(module)} not found"
          end

        {:error, %{message: message, status: :not_found}}

      record ->
        {:ok, record}
    end
  end
end
