defmodule Backend.Seeds do
  def run do
    user =
      Backend.Users.create_user!(%{
        email: Faker.Internet.email(),
        password: "password",
        first_name: Faker.Person.first_name(),
        last_name: Faker.Person.last_name()
      })

    student = Backend.Students.create_student!(user)
    instructor = Backend.Instructors.create_instructor!(user)
    project = Backend.Instructors.create_project!(instructor, %{name: Faker.Lorem.sentence()})

    course =
      Backend.Instructors.create_course!(project, %{name: Faker.Company.name(), price: 100.00})

    payment_integration =
      Backend.Instructors.create_payment_integration!(instructor, %{
        provider: "liqpay",
        credentials: %{
          "public_key" => "sandbox_i7433770906",
          "private_key" => "sandbox_HoElkP0sZdzRJJ20pIA5c15jLfGWPTpDVFnPH0xg"
        }
      })

    course =
      Backend.Instructors.attach_payment_integration_to_course!(course, payment_integration)

    course =
      Backend.Instructors.update_course!(
        course,
        %{
          public_path: "/#{Faker.Lorem.word()}"
        }
      )

    course = Backend.Instructors.publish_course!(course)

    {:ok, _html} = Backend.Payments.request_course_payment_form(course, student)
  end
end
