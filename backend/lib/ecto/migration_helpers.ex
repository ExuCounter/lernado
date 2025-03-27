defmodule Backend.MigrationHelpers do
  use Ecto.Migration

  def create_enum(name, values) when (is_atom(name) or is_binary(name)) and is_list(values) do
    execute(
      "CREATE TYPE #{name} AS ENUM (#{Enum.map_join(values, ",", fn value -> "'#{value}'" end)})",
      "DROP TYPE #{name}"
    )
  end

  def drop_enum(name, values) when (is_atom(name) or is_binary(name)) and is_list(values) do
    execute(
      "DROP TYPE #{name}",
      "CREATE TYPE #{name} AS ENUM (#{Enum.map_join(values, ",", fn value -> "'#{value}'" end)})"
    )
  end
end
