defmodule BackendWeb.Controllers.AuthTest do
  use BackendWeb.ConnCase, async: true

  describe "authentication" do
    test "signs in a user", ctx do
      ctx = ctx |> produce([:user, conn: [:unauthenticated]])

      conn =
        post(ctx.conn, ~p"/auth/login", %{
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
        post(ctx.conn, ~p"/auth/login", %{
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

    test "register", ctx do
      ctx = ctx |> produce(conn: [:unauthenticated])

      conn =
        post(ctx.conn, ~p"/auth/register", %{
          "email" => Faker.Internet.email(),
          "password" => Faker.String.base64(),
          "first_name" => Faker.Person.first_name(),
          "last_name" => Faker.Person.last_name(),
          "preferred_currency" => Faker.Currency.code()
        })

      assert_successfull_response(conn)

      assert %{
               "data" => %{
                 "user" => _
               }
             } =
               Jason.decode!(conn.resp_body)
    end

    test "register with existing email", ctx do
      ctx = ctx |> produce([:user, conn: [:unauthenticated]])

      conn =
        post(ctx.conn, ~p"/auth/register", %{
          "email" => ctx.user.email,
          "password" => ctx.user.password
        })

      assert_unauthorized_response(conn, "Unauthorized.")
    end
  end
end
