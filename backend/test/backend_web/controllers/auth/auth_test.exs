defmodule BackendWeb.Controllers.AuthTest do
  use BackendWeb.ConnCase, async: true

  describe "authentication" do
    test "signs in a user", ctx do
      ctx = ctx |> produce([:user, conn: [:unauthenticated]])

      conn =
        post(ctx.conn, "/auth/login", %{
          "email" => ctx.user.email,
          "password" => ctx.user.password
        })

      assert conn.status == 201
    end

    test "signs in an unexisting user", ctx do
      ctx = ctx |> produce(conn: [:unauthenticated])

      conn =
        post(ctx.conn, "/auth/login", %{
          "email" => Faker.Internet.email(),
          "password" => Faker.String.base64()
        })

      assert conn.status == 401

      assert %{"status" => "error", "message" => "Invalid email or password"} =
               Jason.decode!(conn.resp_body)
    end

    test "signs in an existing user with wrong password", ctx do
      ctx = ctx |> produce([:user, conn: [:unauthenticated]])

      conn =
        post(ctx.conn, "/auth/login", %{
          "email" => ctx.user.email,
          "password" => ctx.user.password <> "wrong"
        })

      assert conn.status == 401

      assert %{"status" => "error", "message" => "Invalid email or password"} =
               Jason.decode!(conn.resp_body)
    end

    test "register", ctx do
      ctx = ctx |> produce(conn: [:unauthenticated])

      conn =
        post(ctx.conn, "/auth/register", %{
          "email" => Faker.Internet.email(),
          "password" => Faker.String.base64(),
          "first_name" => Faker.Person.first_name(),
          "last_name" => Faker.Person.last_name(),
          "preferred_currency" => Faker.Currency.code()
        })

      assert conn.status == 201
    end

    test "register with existing email", ctx do
      ctx = ctx |> produce([:user, conn: [:unauthenticated]])

      conn =
        post(ctx.conn, "/auth/register", %{
          "email" => ctx.user.email,
          "password" => ctx.user.password
        })

      assert conn.status == 400

      assert %{"status" => "error", "message" => "Something went wrong."} =
               Jason.decode!(conn.resp_body)
    end
  end
end
