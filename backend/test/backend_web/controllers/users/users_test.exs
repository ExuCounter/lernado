defmodule BackendWeb.Controllers.UsersTest do
  use BackendWeb.ConnCase, async: true

  @api_users_update_endpoint "/api/users/update"

  describe "users" do
    test "update", ctx do
      ctx = ctx |> produce(conn: [:user_session])

      email = ctx.user.email
      first_name = Faker.Person.first_name()
      last_name = Faker.Person.last_name()
      preferred_currency = Faker.Currency.code()
      user_id = ctx.user.id

      conn =
        post(ctx.conn, @api_users_update_endpoint, %{
          email: email,
          first_name: first_name,
          last_name: last_name,
          preferred_currency: preferred_currency,
          user_id: user_id
        })

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
               json_response(conn, 200)
    end

    test "update with existing email", ctx do
      ctx1 = ctx |> produce([:user, conn: [:user_session]])
      ctx2 = ctx |> produce(:user)

      conn =
        post(ctx1.conn, @api_users_update_endpoint, %{
          email: ctx2.user.email,
          user_id: ctx1.user.id
        })

      assert %{
               "message" => %{
                 "email" => ["has already been taken"]
               }
             } = json_response(conn, 400)
    end

    test "update different user", ctx do
      ctx1 = ctx |> produce([:user, conn: [:user_session]])
      ctx2 = ctx |> produce(:user)

      conn =
        post(ctx1.conn, @api_users_update_endpoint, %{
          email: "newemail@gmail.com",
          user_id: ctx2.user.id
        })

      json_response(conn, 403)
    end
  end
end
