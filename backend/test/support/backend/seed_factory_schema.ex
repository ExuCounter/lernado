defmodule Backend.SeedFactorySchema do
  use SeedFactory.Schema

  command :create_user do
    param(:first_name, generate: &Faker.Person.first_name/0)
    param(:last_name, generate: &Faker.Person.last_name/0)
    param(:email, generate: &Faker.Internet.email/0)
    param(:preferred_currency, generate: &Faker.Currency.code/0)
    param(:password, generate: &Faker.String.base64/0)

    resolve(fn args ->
      with {:ok, user} <- Backend.Users.create_user(args) do
        {:ok, %{user: user}}
      end
    end)

    produce(:user)
  end

  command :create_instructor do
    param(:user, entity: :user)

    resolve(fn args ->
      with {:ok, instructor} <- args.user |> Backend.Instructors.create_instructor() do
        {:ok, %{instructor: instructor}}
      end
    end)

    produce(:instructor)
  end

  command :create_project do
    param(:instructor, entity: :instructor)
    param(:name, generate: &Faker.Lorem.sentence/0)

    resolve(fn args ->
      with {:ok, project} <- args.instructor |> Backend.Instructors.create_project(args) do
        {:ok, %{project: project}}
      end
    end)

    produce(:project)
  end

  command :create_course do
    param(:project, entity: :project)
    param(:name, generate: &Faker.Company.name/0)
    param(:price, value: 0)

    resolve(fn args ->
      with {:ok, course} <- args.project |> Backend.Instructors.create_course(args) do
        {:ok, %{course: course}}
      end
    end)

    produce(:course)
  end

  command :update_course do
    param(:course, entity: :course)
    param(:public_path)
    param(:currency, generate: &Faker.Currency.code/0)
    param(:price, value: 0)

    resolve(fn args ->
      with {:ok, course} <- args.course |> Backend.Instructors.update_course(args) do
        {:ok, %{course: course}}
      end
    end)

    update(:course)
  end

  command :create_course_module do
    param(:course, entity: :course)
    param(:title, generate: &Faker.Lorem.sentence/0)
    param(:description, generate: &Faker.Lorem.paragraph/0)

    resolve(fn args ->
      with {:ok, course_module} <-
             args.course |> Backend.Instructors.create_course_module(args) do
        {:ok, %{course_module: course_module}}
      end
    end)

    produce(:course_module)
  end

  command :create_course_lesson do
    param(:module, entity: :course_module)
    param(:title, generate: &Faker.Lorem.sentence/0)
    param(:description, generate: &Faker.Lorem.paragraph/0)
    param(:type, value: :text)
    param(:video_url)
    param(:content, generate: &Faker.Lorem.paragraph/0)

    resolve(fn args ->
      with {:ok, course_lesson} <-
             args.module |> Backend.Instructors.create_course_lesson(args) do
        {:ok, %{course_lesson: course_lesson}}
      end
    end)

    produce(:course_lesson)
  end

  command :create_payment_integration do
    param(:instructor, entity: :instructor)
    param(:enabled, value: false)

    param(:credentials,
      value: %{
        "public_key" => "public",
        "private_key" => "private"
      }
    )

    param(:provider, value: :liqpay)

    resolve(fn args ->
      with {:ok, payment_integration} <-
             args.instructor |> Backend.Instructors.create_payment_integration(args) do
        {:ok, %{payment_integration: payment_integration}}
      end
    end)

    produce(:payment_integration)
  end

  # different payment integration

  command :enable_payments_for_course do
    param(:payment_integration, entity: :payment_integration)
    param(:course, entity: :course)

    resolve(fn args ->
      with {:ok, course} <-
             Backend.Instructors.attach_payment_integration_to_course(
               args.course,
               args.payment_integration
             ) do
        {:ok, %{course: course}}
      end
    end)

    update(:course)
  end

  command :publish_course do
    param(:course, entity: :course)

    resolve(fn args ->
      with {:ok, course} <- args.course |> Backend.Instructors.publish_course() do
        {:ok, %{course: course}}
      end
    end)

    update(:course)
  end

  trait :with_payments_enabled, :course do
    exec(:enable_payments_for_course)
  end

  trait :with_info_provided, :course do
    from(:with_payments_enabled)

    exec(:update_course,
      args_pattern: %{public_path: "course_path", currency: "USD", price: 100.0}
    )
  end

  trait :published, :course do
    from(:with_info_provided)
    exec(:publish_course)
  end

  command :create_student do
    param(:user, entity: :user)

    resolve(fn args ->
      with {:ok, student} <- args.user |> Backend.Students.create_student() do
        {:ok, %{student: student}}
      end
    end)

    produce(:student)
  end

  command :create_student_enrollment do
    param(:student, entity: :student)
    param(:course, entity: :course)

    resolve(fn args ->
      with {:ok, enrollment} <-
             args.student |> Backend.Students.create_enrollment(args.course) do
        {:ok, %{student_enrollment: enrollment}}
      end
    end)

    produce(:student_enrollment)
  end

  # command :create_instructor_payment do
  #   param(:course, entity: :course, with_traits: [:published])

  #   resolve(fn args ->
  #     with {:ok, payment} <-
  #            Backend.Payments.create_instructor_course_payment_pending(args.course) do
  #       {:ok, %{instructor_payment: payment}}
  #     end
  #   end)

  #   produce(:instructor_payment)
  # end

  # command :create_student_payment do
  #   param(:student, entity: :student)
  #   param(:course, entity: :course, with_traits: [:published])
  #   param(:instructor_payment, entity: :instructor_payment)

  #   resolve(fn args ->
  #     with {:ok, payment} <-
  #            args.student
  #            |> Backend.Payments.create_student_course_payment_pending(
  #              args.course,
  #              args.instructor_payment
  #            ) do
  #       {:ok, %{student_payment: payment}}
  #     end
  #   end)

  #   produce(:student_payment)
  # end

  command :request_course_payment_form do
    param(:student, entity: :student)
    param(:course, entity: :course, with_traits: [:published])

    resolve(fn args ->
      with {:ok, %{student_payment: student_payment}} <-
             Backend.Payments.request_course_payment_form(
               args.course,
               args.student
             ) do
        {:ok, %{student_payment: student_payment}}
      end
    end)

    produce(:student_payment)
  end
end
