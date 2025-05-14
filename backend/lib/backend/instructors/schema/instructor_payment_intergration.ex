defmodule Backend.Instructors.Schema.PaymentIntegration do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "instructor_payment_integrations" do
    field :provider, Ecto.Enum, values: [:liqpay]
    field :enabled, :boolean, default: false
    field :credentials, :map

    belongs_to :instructor, Backend.Instructors.Schema.Instructor, type: :binary_id

    timestamps()
  end

  def create_changeset(instructor, attrs) do
    %__MODULE__{
      instructor_id: instructor.id,
      enabled: false,
      credentials: %{}
    }
    |> cast(attrs, [:provider, :enabled, :instructor_id, :credentials])
    |> validate_required([:provider, :enabled, :credentials])
    |> foreign_key_constraint(:instructor_id)
  end

  def update_changeset(integration, attrs) do
    integration
    |> cast(attrs, [:enabled, :credentials])
    |> validate_required([:enabled, :credentials])
  end
end
