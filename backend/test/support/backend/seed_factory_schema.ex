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

  command :create_instructor_project do
    param(:user, entity: :user)
    param(:instructor, entity: :instructor)
    param(:name, generate: &Faker.Lorem.sentence/0)

    resolve(fn args ->
      with {:ok, project} <- args.instructor |> Backend.Instructors.create_project(args) do
        {:ok, %{instructor_project: project}}
      end
    end)

    produce(:instructor_project)
  end
end
