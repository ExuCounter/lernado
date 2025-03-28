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

    test "update own project", ctx do
      ctx = ctx |> produce([:user, :instructor, :instructor_project, conn: [:user_session]])

      name = Faker.Company.name()

      conn =
        put(ctx.conn, "/api/instructors/projects/update/#{ctx.instructor_project.id}", %{
          "name" => name
        })

      assert conn.status == 200

      assert %{
               "data" => %{
                 "project" => %{
                   "name" => ^name
                 }
               }
             } =
               Jason.decode!(conn.resp_body)

      conn =
        put(ctx.conn, "/api/instructors/projects/update/#{ctx.instructor_project.id}", %{
          "name" => "short"
        })

      assert_bad_request_response(conn)
    end

    test "update stranger project", ctx do
      ctx1 = ctx |> produce([:user, :instructor, :instructor_project])
      ctx2 = ctx |> produce([:user, :instructor, conn: [:user_session]])

      conn =
        put(ctx2.conn, "/api/instructors/projects/update/#{ctx1.instructor_project.id}", %{
          "name" => Faker.Company.name()
        })

      assert_forbidden_response(conn)
    end
  end
end
