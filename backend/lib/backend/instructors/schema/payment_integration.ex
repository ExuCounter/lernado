defmodule Backend.Instructors.Schema.PaymentIntegration do
  use Backend, :schema

  schema "instructor_payment_integrations" do
    field :provider, Ecto.Enum, values: [:liqpay]
    field :credentials, :map

    belongs_to :instructor, Backend.Instructors.Schema.Instructor

    has_many :payments, Backend.Instructors.Schema.InstructorPayment,
      foreign_key: :payment_integration_id

    has_many :courses, Backend.Instructors.Schema.Course, foreign_key: :payment_integration_id

    timestamps()
  end

  def create_changeset(instructor, attrs) do
    %__MODULE__{
      credentials: %{}
    }
    |> cast(attrs, [:provider, :credentials])
    |> validate_required([:provider, :credentials])
    |> put_assoc(:instructor, instructor)
  end

  def update_changeset(integration, attrs) do
    integration
    |> cast(attrs, [:credentials])
    |> validate_required([:credentials])
  end
end
