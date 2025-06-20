defmodule Backend do
  @moduledoc """
  Backend keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @doc """
  Share the common settings between schemas.

  ## Example
      use Backend, :schema
  """
  def schema do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      @primary_key {:id, :binary_id, read_after_writes: true}
      @foreign_key_type :binary_id
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
