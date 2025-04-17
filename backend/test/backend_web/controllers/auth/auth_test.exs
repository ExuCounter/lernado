defmodule BackendWeb.Controllers.AuthTest do
  use BackendWeb.ConnCase, async: true

  @api_auth_login_endpoint "/auth/login"

  describe "authentication" do
    test "signs in a user", ctx do
      ctx = ctx |> produce([:user, conn: [:unauthenticated]])

      conn =
        post(ctx.conn, @api_auth_login_endpoint, %{
          "email" => ctx.user.email,
          "password" => ctx.user.password
        })

      assert_successfull_response(conn)

      assert %{
               "data" => %{
                 "user" => _
               }
             } =
               Jason.decode!(conn.resp_body)
    end

    test "signs in an unexisting user", ctx do
      ctx = ctx |> produce(conn: [:unauthenticated])

      conn =
        post(ctx.conn, @api_auth_login_endpoint, %{
          "email" => Faker.Internet.email(),
          "password" => Faker.String.base64()
        })

      assert_unauthorized_response(conn, "Invalid email or password")
    end

    test "signs in an existing user with wrong password", ctx do
      ctx = ctx |> produce([:user, conn: [:unauthenticated]])

      conn =
        post(ctx.conn, ~p"/auth/login", %{
          "email" => ctx.user.email,
          "password" => ctx.user.password <> "wrong"
        })

      assert_unauthorized_response(conn, "Invalid email or password")
    end

    @api_auth_register_endpoint "/auth/register"

    test "register", ctx do
      ctx = ctx |> produce(conn: [:unauthenticated])

      email = Faker.Internet.email()
      password = Faker.String.base64()
      first_name = Faker.Person.first_name()
      last_name = Faker.Person.last_name()

      conn =
        post(ctx.conn, @api_auth_register_endpoint, %{
          "email" => email,
          "password" => password,
          "first_name" => first_name,
          "last_name" => last_name
        })

      assert %{
               "data" => %{
                 "user" => %{
                   "email" => ^email,
                   "first_name" => ^first_name,
                   "last_name" => ^last_name
                 }
               }
             } =
               Jason.decode!(conn.resp_body)
    end

    test "register with existing email", ctx do
      ctx = ctx |> produce([:user, conn: [:unauthenticated]])

      conn =
        post(ctx.conn, @api_auth_register_endpoint, %{
          "email" => ctx.user.email,
          "password" => ctx.user.password,
          "first_name" => Faker.Person.first_name(),
          "last_name" => Faker.Person.last_name()
        })

      assert_bad_request_response(conn, %{"email" => ["has already been taken"]})
    end
  end
end
