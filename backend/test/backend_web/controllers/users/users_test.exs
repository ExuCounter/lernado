defmodule BackendWeb.Controllers.UsersTest do
  use BackendWeb.ConnCase, async: true

  describe "users" do
    test "update", ctx do
      ctx = ctx |> produce(conn: [:user_session])

      data = %{
        "email" => ctx.user.email,
        "first_name" => Faker.Person.first_name(),
        "last_name" => Faker.Person.last_name(),
        "preferred_currency" => Faker.Currency.code()
      }

      conn = put(ctx.conn, "/api/users/update/#{ctx.user.id}", data)

      email = data["email"]
      first_name = data["first_name"]
      last_name = data["last_name"]
      preferred_currency = data["preferred_currency"]

      assert %{
               "data" => %{
                 "user" => %{
                   "email" => ^email,
                   "first_name" => ^first_name,
                   "last_name" => ^last_name,
                   "preferred_currency" => ^preferred_currency
                 }
               }
             } =
               Jason.decode!(conn.resp_body)
    end

    test "update with existing email", ctx do
      ctx1 = ctx |> produce([:user, conn: [:user_session]])
      ctx2 = ctx |> produce(:user)

      conn = put(ctx1.conn, "/api/users/update/#{ctx1.user.id}", %{email: ctx2.user.email})

      assert_bad_request_response(conn, %{"email" => ["has already been taken"]})
    end

    test "update different user", ctx do
      ctx1 = ctx |> produce([:user, conn: [:user_session]])
      ctx2 = ctx |> produce(:user)

      conn = put(ctx1.conn, "/api/users/update/#{ctx2.user.id}", %{email: "newemail@gmail.com"})

      assert_forbidden_response(conn)
    end
  end
end
