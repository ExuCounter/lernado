defmodule Backend.Instructors.Payments.TransactionType do
  use EctoEnum,
    type: :payment_type,
    enums: [
      :course_payment_from_student,
      :service_fee
    ]
end
