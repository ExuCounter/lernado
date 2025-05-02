defmodule Backend.Instructors.Payments.TransactionStatus do
  use EctoEnum,
    type: :payment_status,
    enums: [
      :pending,
      :succeeded,
      :failed
    ]
end
