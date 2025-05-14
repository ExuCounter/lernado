defmodule Backend.Payments.Queries do
  import Ecto.Query

  def enabled_payment_integrations(
        query \\ Backend.Instructors.Schema.PaymentIntegration,
        instructor_id
      ) do
    from i in query,
      where: i.instructor_id == ^instructor_id,
      where: i.enabled == true
  end
end
