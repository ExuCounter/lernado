defmodule BackendWeb.Controllers.InstructorsTest do
  use BackendWeb.ConnCase, async: true

  describe "instructors" do
    test "create instructor", ctx do
      ctx = ctx |> produce([:user, conn: [:user_session]])

      conn = post(ctx.conn, ~p"/api/instructors/create", %{})

      assert conn.status == 200

      conn = post(ctx.conn, ~p"/api/instructors/create", %{})

      assert_bad_request_response(conn, %{"user_id" => ["has already been taken"]})
    end

    test "create instructor project", ctx do
      ctx = ctx |> produce([:user, :instructor, conn: [:user_session]])

      name = Faker.Company.name()

      conn = post(ctx.conn, ~p"/api/instructors/projects/create", %{"name" => name})

      assert conn.status == 200

      conn = post(ctx.conn, ~p"/api/instructors/projects/create", %{"name" => name})

      assert_bad_request_response(conn, %{"name" => ["has already been taken"]})
    end

    test "update own project", ctx do
      ctx = ctx |> produce([:user, :instructor, :project, conn: [:user_session]])

      name = Faker.Company.name()

      conn =
        put(ctx.conn, ~p"/api/instructors/projects/update", %{
          "project_id" => ctx.project.id,
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
        put(ctx.conn, ~p"/api/instructors/projects/update", %{
          "project_id" => ctx.project.id,
          "name" => "short"
        })

      assert_bad_request_response(conn, %{"name" => ["should be at least 6 character(s)"]})
    end

    test "update stranger project", ctx do
      ctx1 = ctx |> produce([:user, :instructor, :project])
      ctx2 = ctx |> produce([:user, :instructor, conn: [:user_session]])

      conn =
        put(ctx2.conn, ~p"/api/instructors/projects/update", %{
          "name" => Faker.Company.name(),
          "project_id" => ctx1.project.id
        })

      assert_forbidden_response(conn)
    end

    test "create course", ctx do
      ctx = ctx |> produce([:user, :instructor, :project, conn: [:user_session]])

      name = Faker.Company.name()
      project_id = ctx.project.id

      conn =
        post(ctx.conn, ~p"/api/instructors/courses/create", %{
          "project_id" => project_id,
          "name" => name
        })

      assert_successfull_response(conn)

      assert %{
               "data" => %{
                 "course" => %{
                   "name" => ^name,
                   "project" => %{"id" => ^project_id},
                   "price" => +0.0,
                   "currency" => "USD",
                   "description" => "",
                   "status" => "draft"
                 }
               }
             } =
               Jason.decode!(conn.resp_body)

      conn =
        post(ctx.conn, ~p"/api/instructors/courses/create", %{
          "name" => name,
          "project_id" => ctx.project.id
        })

      assert_bad_request_response(conn, %{"name" => ["has already been taken"]})

      conn =
        post(ctx.conn, ~p"/api/instructors/courses/create", %{
          "project_id" => project_id,
          "name" => name <> "2",
          "price" => -5.0
        })

      assert_bad_request_response(conn, %{"price" => ["must be greater than or equal to 0"]})
    end

    test "update own course", ctx do
      ctx =
        ctx
        |> produce([
          :user,
          :instructor,
          :project,
          :course,
          conn: [:user_session]
        ])

      conn =
        put(ctx.conn, ~p"/api/instructors/courses/update", %{
          "course_id" => ctx.course.id,
          "name" => Faker.Company.name(),
          "price" => -5.0
        })

      assert_bad_request_response(conn, %{"price" => ["must be greater than or equal to 0"]})
    end

    test "update non-existing course", ctx do
      ctx =
        ctx
        |> produce([
          :user,
          :instructor,
          :project,
          :course,
          conn: [:user_session]
        ])

      conn =
        put(ctx.conn, ~p"/api/instructors/courses/update", %{
          "course_id" => Faker.UUID.v4(),
          "name" => Faker.Company.name(),
          "price" => 5.0
        })

      assert_not_found_response(conn)
    end

    test "update stanger course", ctx do
      ctx1 = ctx |> produce([:user, :instructor, :project, :course])
      ctx2 = ctx |> produce([:user, conn: [:user_session]])

      conn =
        put(ctx2.conn, ~p"/api/instructors/courses/update", %{
          "course_id" => ctx1.course.id,
          "name" => Faker.Company.name()
        })

      assert_forbidden_response(conn)
    end

    test "create course module", ctx do
      ctx =
        ctx
        |> produce([
          :user,
          :instructor,
          :project,
          :course,
          conn: [:user_session]
        ])

      course_id = ctx.course.id

      conn =
        post(ctx.conn, ~p"/api/instructors/courses/modules/create", %{
          "course_id" => course_id,
          "title" => "Title",
          "description" => "Description"
        })

      assert %{
               "data" => %{
                 "module" => %{
                   "title" => "Title",
                   "description" => "Description",
                   "course" => %{"id" => ^course_id},
                   "order_index" => 0
                 }
               }
             } = Jason.decode!(conn.resp_body)

      conn =
        post(ctx.conn, ~p"/api/instructors/courses/modules/create", %{
          "course_id" => ctx.course.id,
          "title" => "Title2",
          "description" => "Description"
        })

      assert %{
               "data" => %{
                 "module" => %{
                   "order_index" => 1
                 }
               }
             } = Jason.decode!(conn.resp_body)

      conn =
        post(ctx.conn, ~p"/api/instructors/courses/modules/create", %{
          "course_id" => ctx.course.id,
          "title" => "Title",
          "description" => "Description"
        })

      assert_bad_request_response(conn, %{"title" => ["has already been taken"]})
    end

    test "update non-existing course module", ctx do
      ctx =
        ctx
        |> produce([
          :user,
          :instructor,
          :project,
          :course,
          conn: [:user_session]
        ])

      conn =
        put(ctx.conn, ~p"/api/instructors/courses/modules/update", %{
          "module_id" => Faker.UUID.v4(),
          "title" => "Title",
          "description" => "Description"
        })

      assert_not_found_response(conn)
    end

    test "update stranger course module", ctx do
      ctx1 =
        ctx
        |> produce([
          :user,
          :instructor,
          :project,
          :course,
          :course_module
        ])

      ctx2 = ctx |> produce([:user, conn: [:user_session]])

      conn =
        put(ctx2.conn, ~p"/api/instructors/courses/modules/update", %{
          "module_id" => ctx1.course_module.id,
          "title" => "Title",
          "description" => "Description"
        })

      assert_forbidden_response(conn)
    end

    test "create course lesson", ctx do
      ctx =
        ctx
        |> produce([
          :user,
          :instructor,
          :project,
          :course,
          :course_module,
          conn: [:user_session]
        ])

      module_id = ctx.course_module.id

      conn =
        post(ctx.conn, ~p"/api/instructors/courses/lessons/create", %{
          "module_id" => module_id,
          "title" => "Text Lesson 1",
          "content" => "Content",
          "type" => "text"
        })

      assert %{
               "data" => %{
                 "lesson" => %{
                   "title" => "Text Lesson 1",
                   "module" => %{"id" => ^module_id},
                   "order_index" => 0,
                   "text_details" => %{
                     "content" => "Content"
                   }
                 }
               }
             } = Jason.decode!(conn.resp_body)

      conn =
        post(ctx.conn, ~p"/api/instructors/courses/lessons/create", %{
          "module_id" => ctx.course_module.id,
          "title" => "Text Lesson 2",
          "content" => "Description",
          "type" => "text"
        })

      assert %{
               "data" => %{
                 "lesson" => %{
                   "order_index" => 1
                 }
               }
             } = Jason.decode!(conn.resp_body)

      conn =
        post(ctx.conn, ~p"/api/instructors/courses/lessons/create", %{
          "module_id" => ctx.course_module.id,
          "title" => "Text Lesson 2",
          "content" => "Content",
          "type" => "text"
        })

      assert_bad_request_response(conn, %{"title" => ["has already been taken"]})

      conn =
        post(ctx.conn, ~p"/api/instructors/courses/lessons/create", %{
          "module_id" => ctx.course_module.id,
          "title" => "Video Lesson 1",
          "type" => "video",
          "video_url" => "https://youtube.com/video"
        })

      assert %{
               "data" => %{
                 "lesson" => %{
                   "title" => "Video Lesson 1",
                   "module" => %{"id" => ^module_id},
                   "order_index" => 2,
                   "video_details" => %{
                     "video_url" => "https://youtube.com/video"
                   }
                 }
               }
             } = Jason.decode!(conn.resp_body)
    end

    test "update non-existing course lesson", ctx do
      ctx =
        ctx
        |> produce([
          :user,
          :instructor,
          :project,
          :course,
          :course_module,
          conn: [:user_session]
        ])

      conn =
        put(ctx.conn, ~p"/api/instructors/courses/lessons/update", %{
          "lesson_id" => Faker.UUID.v4(),
          "title" => "Text Lesson 1",
          "content" => "Content",
          "type" => "text"
        })

      assert_not_found_response(conn)
    end

    test "update stranger course lesson", ctx do
      ctx1 =
        ctx
        |> produce([
          :user,
          :instructor,
          :project,
          :course,
          :course_module,
          :course_lesson
        ])

      ctx2 = ctx |> produce([:user, conn: [:user_session]])

      conn =
        put(ctx2.conn, ~p"/api/instructors/courses/lessons/update", %{
          "lesson_id" => ctx1.course_lesson.id,
          "title" => "Text Lesson 1",
          "content" => "Content",
          "type" => "text"
        })

      assert_forbidden_response(conn)
    end

    test "update own course and change it type", ctx do
      ctx =
        ctx
        |> produce([
          :user,
          :instructor,
          :project,
          :course,
          :course_module,
          :course_lesson,
          conn: [:user_session]
        ])

      conn =
        put(ctx.conn, ~p"/api/instructors/courses/lessons/update", %{
          "lesson_id" => ctx.course_lesson.id,
          "title" => "Text Lesson 1",
          "type" => "video",
          "video_url" => "https://youtube.com/video"
        })

      assert_successfull_response(conn)

      assert %{
               "data" => %{
                 "lesson" => %{
                   "title" => "Text Lesson 1",
                   "type" => "video",
                   "video_details" => %{
                     "video_url" => "https://youtube.com/video"
                   }
                 }
               }
             } = Jason.decode!(conn.resp_body)
    end

    test "delete course lesson", ctx do
      ctx =
        ctx
        |> produce([
          :user,
          :instructor,
          :project,
          :course,
          :course_module,
          :course_lesson,
          conn: [:user_session]
        ])

      conn =
        put(ctx.conn, ~p"/api/instructors/courses/lessons/delete", %{
          "lesson_id" => ctx.course_lesson.id
        })

      assert_successfull_response(conn)
    end

    test "publish course", ctx do
      ctx =
        ctx
        |> produce([
          :user,
          :instructor,
          :project,
          :course,
          conn: [:user_session]
        ])

      conn =
        put(ctx.conn, ~p"/api/instructors/courses/publish", %{
          "course_id" => ctx.course.id
        })

      assert_bad_request_response(conn, %{"public_path" => ["can't be blank"]})

      Backend.Instructors.update_course(ctx.course, %{public_path: "course_path"})

      conn =
        put(ctx.conn, ~p"/api/instructors/courses/publish", %{
          "course_id" => ctx.course.id
        })

      assert %{
               "data" => %{
                 "course" => %{
                   "status" => "published"
                 }
               }
             } = Jason.decode!(conn.resp_body)
    end

    test "publish stranger course", ctx do
      ctx1 =
        ctx
        |> produce([
          :user,
          :instructor,
          :project,
          :course
        ])

      ctx2 = ctx |> produce([:user, conn: [:user_session]])

      conn =
        put(ctx2.conn, ~p"/api/instructors/courses/publish", %{
          "course_id" => ctx1.course.id
        })

      assert_forbidden_response(conn)
    end

    test "publish already published course", ctx do
      ctx =
        ctx
        |> produce([
          :user,
          :instructor,
          :project,
          :course,
          conn: [:user_session]
        ])

      Backend.Instructors.update_course(ctx.course, %{public_path: "course_path"})

      put(ctx.conn, ~p"/api/instructors/courses/publish", %{
        "course_id" => ctx.course.id
      })

      conn =
        put(ctx.conn, ~p"/api/instructors/courses/publish", %{
          "course_id" => ctx.course.id
        })

      assert_bad_request_response(conn, %{"status" => ["Course is already published"]})
    end
  end

  test "update course lesson video", ctx do
    ctx = ctx |> exec(:create_course_lesson, type: :video) |> produce(conn: [:user_session])

    upload_data = %Plug.Upload{
      path: "test/fixtures/dummy.mp4",
      filename: "dummy.mp4",
      content_type: "video/mp4"
    }

    expect(
      Backend.AWS.DispatcherMock,
      :multipart_upload,
      fn _bucket, key, path ->
        assert key == "courses/#{ctx.course.id}/videos/dummy.mp4"
        assert path == "test/fixtures/dummy.mp4"

        {:ok, "https://aws.amazon.com/#{key}"}
      end
    )

    conn =
      post(ctx.conn, ~p"/api/instructors/courses/videos/upload", %{
        "lesson_id" => ctx.course_lesson.id,
        "video" => upload_data
      })

    assert %{
             "data" => %{
               "lesson" => %{
                 "video_details" => %{
                   "video_url" => video_url
                 }
               }
             }
           } = Jason.decode!(conn.resp_body)

    assert video_url =~ ~r/https:\/\/.*dummy\.mp4/
  end
end
