defmodule BackendWeb.Controllers.AuthTest do
  use BackendWeb.ConnCase, async: true

  @api_auth_login_endpoint "/auth/login"

  describe "authentication" do
    test "signs in a user", ctx do
      ctx =
        ctx
        |> exec(:create_user,
          email: "myemail@gmail.com",
          password: "my_password",
          first_name: "John",
          last_name: "Doe"
        )
        |> produce(conn: [:unauthenticated])

      conn =
        post(ctx.conn, @api_auth_login_endpoint, %{
          "email" => "myemail@gmail.com",
          "password" => "my_password"
        })

      assert %{
               "data" => %{
                 "user" => _
               }
             } = json_response(conn, 200)
    end

    test "signs in an unexisting user", ctx do
      ctx = ctx |> produce(conn: [:unauthenticated])

      conn =
        post(ctx.conn, @api_auth_login_endpoint, %{
          "email" => Faker.Internet.email(),
          "password" => Faker.String.base64()
        })

      assert %{
               "message" => "You are not authorized to perform this action."
             } = json_response(conn, 403)
    end

    test "signs in an existing user with wrong password", ctx do
      ctx = ctx |> produce([:user, conn: [:unauthenticated]])

      conn =
        post(ctx.conn, ~p"/auth/login", %{
          "email" => ctx.user.email,
          "password" => "wrong_password"
        })

      assert %{
               "message" => "You are not authorized to perform this action."
             } = json_response(conn, 403)
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

      assert %{
               "data" => %{
                 "user" => %{
                   "email" => ^email,
                   "first_name" => ^first_name,
                   "last_name" => ^last_name
                 }
               }
             } = json_response(conn, 200)
    end

    test "register with existing email", ctx do
      ctx = ctx |> produce([:user, conn: [:unauthenticated]])

      conn =
        post(ctx.conn, @api_auth_register_endpoint, %{
          "email" => ctx.user.email,
          "password" => "my_new_password",
          "first_name" => Faker.Person.first_name(),
          "last_name" => Faker.Person.last_name()
        })

      assert %{
               "message" => %{
                 "email" => ["has already been taken"]
               }
             } = json_response(conn, 400)
    end
  end
end
