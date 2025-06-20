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
      instructor_id: instructor.id,
      credentials: %{}
    }
    |> cast(attrs, [:provider, :instructor_id, :credentials])
    |> validate_required([:provider, :credentials])
    |> foreign_key_constraint(:instructor_id)
  end

  def update_changeset(integration, attrs) do
    integration
    |> cast(attrs, [:credentials])
    |> validate_required([:credentials])
  end
end
