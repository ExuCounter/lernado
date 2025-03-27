defmodule BackendWeb.InstructorsController do
  use BackendWeb, :controller

  def create_instructor(conn, params) do
    result = Backend.Instructors.create_instructor(params)

    case result do
      {:ok, instructor} ->
        conn
        |> put_status(201)
        |> json(%{
          instructor: instructor,
          message: "Instructor created successfully.",
          status: "success"
        })

      {:error, _changeset} ->
        conn
        |> put_status(400)
        |> json(%{
          message: "Something went wrong.",
          status: "error"
        })
    end
  end

  def create_project(conn, params) do
    result = Backend.Instructors.create_project(params)

    case result do
      {:ok, project} ->
        conn
        |> put_status(201)
        |> json(%{
          project: project,
          message: "Project created successfully.",
          status: "success"
        })

      {:error, _changeset} ->
        conn
        |> put_status(400)
        |> json(%{
          message: "Something went wrong.",
          status: "error"
        })
    end
  end

  def update_project(conn, %{"id" => nil}) do
    conn
    |> put_status(400)
    |> json(%{
      message: "Project ID is required.",
      status: "error"
    })
  end

  def update_project(conn, params) do
    project = Backend.Instructors.find_project_by_id(params["id"])

    if is_nil(project) do
      conn
      |> put_status(404)
      |> json(%{
        message: "Project not found.",
        status: "error"
      })
    else
      result = Backend.Instructors.update_project(project, params)

      case result do
        {:ok, project} ->
          conn
          |> put_status(200)
          |> json(%{
            project: project,
            message: "Project updated successfully.",
            status: "success"
          })

        {:error, _changeset} ->
          conn
          |> put_status(400)
          |> json(%{
            message: "Something went wrong.",
            status: "error"
          })
      end
    end
  end

  def create_course(conn, params) do
    result = Backend.Instructors.create_course(params)

    case result do
      {:ok, course} ->
        conn
        |> put_status(201)
        |> json(%{
          course: course,
          message: "Course created successfully.",
          status: "success"
        })

      {:error, _changeset} ->
        conn
        |> put_status(400)
        |> json(%{
          message: "Something went wrong.",
          status: "error"
        })
    end
  end

  def update_course(conn, %{"id" => nil}) do
    conn
    |> put_status(400)
    |> json(%{
      message: "Course ID is required.",
      status: "error"
    })
  end

  def update_course(conn, params) do
    course = Backend.Instructors.find_course_by_id(params["id"])

    if is_nil(course) do
      conn
      |> put_status(404)
      |> json(%{
        message: "Course not found.",
        status: "error"
      })
    else
      result = Backend.Instructors.update_course(course, params)

      case result do
        {:ok, course} ->
          conn
          |> put_status(200)
          |> json(%{
            course: course,
            message: "Course updated successfully.",
            status: "success"
          })

        {:error, _changeset} ->
          conn
          |> put_status(400)
          |> json(%{
            message: "Something went wrong.",
            status: "error"
          })
      end
    end
  end
end
