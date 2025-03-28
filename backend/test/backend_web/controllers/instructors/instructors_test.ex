defmodule BackendWeb.Controllers.InstructorsTest do
  use BackendWeb.ConnCase, async: true

  describe "instructors" do
    test "create instructor", ctx do
      ctx = ctx |> produce([:user, conn: [:user_session]])

      conn = put(ctx.conn, "/api/instructors/create", %{})

      assert conn.status == 200
    end

    test "create instructor project", ctx do
      ctx = ctx |> produce([:user, :instructor, conn: [:user_session]])

      conn = put(ctx.conn, "/api/instructors/projects/create", %{"name" => Faker.Company.name()})

      assert conn.status == 200
    end

    test "update stranger project", ctx do
      ctx1 = ctx |> produce([:user, :instructor, :instructor_project])
      ctx2 = ctx |> produce([:user, :instructor, conn: [:user_session]])

      conn =
        put(ctx2.conn, "/api/instructors/projects/update/#{ctx1.instructor_project.id}", %{
          "name" => Faker.Company.name()
        })

      assert conn.status == 403

      assert %{
               "status" => "error",
               "message" => "You are not authorized to perform this action."
             } =
               Jason.decode!(conn.resp_body)
    end
  end
end
