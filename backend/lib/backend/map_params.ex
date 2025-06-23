defmodule Backend.MapParams do
  @doc """
  Map params for given module using mapper

  ## Examples

    iex> Pt.MapParams.map(
    ...>   %{
    ...>     "project_name" => "New project",
    ...>     "project_description" => "Description",
    ...>     "project_status" => "live",
    ...>     "angle_name" => "New angle",
    ...>     "angle_brief" => "Brief",
    ...>     "project_count" => nil,
    ...>     "requested_calls" => "20",
    ...>     "companies" => ["Company 1", "Company 2", "Company 3, Company 4, llc."],
    ...>     "target_company" => ""
    ...>   },
    ...>   :project,
    ...>   %{
    ...>     project: %{
    ...>       name: [from: "project_name", map: &String.upcase/1],
    ...>       description: [from: "project_description"],
    ...>       status: [from: "project_status"],
    ...>       count: [from: "project_count", default: 0],
    ...>       companies: [from: "companies", type: {:array, :string}, split: ",", ignore: ["llc", "plc", "limited", "corp", "inc", "gmbh", "ltd", "co"]],
    ...>       requested_calls: [from: "requested_calls", type: :integer],
    ...>       target_company: [from: "target_company", type: :string]
    ...>     }
    ...>   }
    ...>)
    %{
      name: "NEW PROJECT",
      description: "Description",
      companies: ["Company 1", "Company 2", "Company 3", "Company 4"],
      status: "live",
      requested_calls: 20,
      count: 0,
      target_company: nil
    }
  """
  @spec map(params :: map(), module :: module(), mapper :: map()) :: map()
  def map(params, module, mapper) do
    mapper
    |> Map.fetch!(module)
    |> Enum.reduce(%{}, fn {key, options}, result ->
      from = Keyword.fetch!(options, :from)

      with true <- Map.has_key?(params, from),
           {:ok, value} <- cast_field(params[from], options) do
        Map.put(result, key, value)
      else
        _ ->
          result
      end
    end)
  end

  defp cast_field(raw_value, options) do
    value =
      cond do
        (is_nil(raw_value) || raw_value == "") && Keyword.has_key?(options, :default) ->
          options[:default]

        Keyword.has_key?(options, :map) ->
          options[:map].(raw_value)

        Keyword.has_key?(options, :split) ->
          split_text(raw_value, options[:split], options[:ignore] || [])

        true ->
          raw_value
      end

    cast_typed_field(options[:type], value)
  end

  defp cast_typed_field(:string, value) do
    trimmed = String.trim(value || "")

    cast_value =
      if trimmed == "" do
        nil
      else
        trimmed
      end

    {:ok, cast_value}
  end

  defp cast_typed_field(nil, value) do
    {:ok, value}
  end

  defp cast_typed_field(type, value) do
    Ecto.Type.cast(type, value)
  end

  defp split_text(value, split_by, ignore_list) do
    value
    |> List.wrap()
    |> Enum.map(fn v -> String.split(v, split_by, trim: true) end)
    |> List.flatten()
    |> Enum.map(&String.trim/1)
    |> Enum.reject(fn v ->
      clean_value = v |> String.downcase() |> String.replace(".", "")
      clean_value == "" || clean_value in ignore_list
    end)
  end
end
