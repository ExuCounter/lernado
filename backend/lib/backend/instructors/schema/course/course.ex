defmodule Backend.Instructors.Schema.Course do
  use Backend, :schema

  @derive {Jason.Encoder,
           only: [
             :id,
             :name,
             :description,
             :status,
             :price,
             :currency,
             :public_path,
             :project,
             :inserted_at,
             :updated_at
           ]}
  schema "courses" do
    field :name, :string
    field :description, :string
    field :status, Backend.Instructors.InstructorProjectStatus
    field :price, :decimal
    field :currency, :string
    field :public_path, :string

    belongs_to :project, Backend.Instructors.Schema.Project

    belongs_to :payment_integration, Backend.Instructors.Schema.PaymentIntegration,
      foreign_key: :payment_integration_id

    has_many :modules, Backend.Instructors.Schema.Course.Module, foreign_key: :course_id
    timestamps()
  end

  def create_changeset(project, attrs) do
    %__MODULE__{
      price: 0.0,
      currency: "USD",
      description: "",
      status: :draft
    }
    |> cast(attrs, [:name, :description, :price, :currency])
    |> validate_required([:name, :status, :price, :currency])
    |> put_assoc(:project, project)
    |> unique_constraint(:name)
    |> foreign_key_constraint(:project_id)
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_length(:name, min: 6)
  end

  def update_changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :description, :price, :currency, :public_path])
    |> validate_required([:name, :price, :currency])
    |> unique_constraint(:name)
    |> validate_length(:name, min: 6)
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:project_id)
    |> unique_constraint(:public_path)
    |> validate_length(:currency, is: 3)
  end

  def update_payment_integration_changeset(course, payment_integration) do
    course
    |> Backend.Repo.preload(:payment_integration)
    |> Ecto.Changeset.change()
    |> put_assoc(:payment_integration, payment_integration)
  end

  def publish_changeset(%{status: :draft} = course) do
    changeset = course |> Ecto.Changeset.change()
    price = get_field(changeset, :price)
    payment_integration_id = get_field(changeset, :payment_integration_id)

    changeset =
      if Decimal.compare(price, 0) != :eq and is_nil(payment_integration_id) do
        changeset
        |> add_error(:payment_integration_id, "Payment integration is required for paid courses")
      else
        changeset
      end

    changeset
    |> change(status: :published)
    |> validate_required([:status, :currency, :price, :public_path])
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> unique_constraint(:public_path)
    |> validate_length(:currency, is: 3)
  end

  def publish_changeset(course) do
    course
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.add_error(:status, "Course is already published")
  end
end
