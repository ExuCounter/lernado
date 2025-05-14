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
      with {:ok, instructor} <- args.user |> Backend.Instructors.create_instructor(args) do
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

    resolve(fn args ->
      with {:ok, course} <- args.project |> Backend.Instructors.create_course(args) do
        {:ok, %{course: course}}
      end
    end)

    produce(:course)
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
    param(:credentials, value: %{})
    param(:provider)

    resolve(fn args ->
      with {:ok, payment_integration} <-
             args.instructor |> Backend.Instructors.create_payment_integration(args) do
        {:ok, %{payment_integration: payment_integration}}
      end
    end)

    produce(:payment_integration)
  end

  command :enable_payment_integration do
    param(:payment_integration, entity: :payment_integration)

    resolve(fn args ->
      with {:ok, payment_integration} <-
             args.payment_integration |> Backend.Instructors.enable_payment_integration() do
        {:ok, %{payment_integration: payment_integration}}
      end
    end)

    update(:payment_integration)
  end

  command :publish_course do
    param(:course, entity: :course)
    param(:public_path)
    param(:price, generate: &Faker.Commerce.price/0)
    param(:currency, generate: &Faker.Currency.code/0)

    resolve(fn args ->
      with {:ok, course} <- args.course |> Backend.Instructors.publish_course(args) do
        {:ok, %{course: course}}
      end
    end)

    update(:course)
  end
end
