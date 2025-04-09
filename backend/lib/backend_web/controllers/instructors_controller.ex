defmodule BackendWeb.InstructorsController do
  use BackendWeb, :controller

  def create_instructor(conn, params) do
    with true <- Backend.Instructors.authorize(:create_instructor, conn.assigns.current_user),
         {:ok, instructor} <-
           Backend.Instructors.create_instructor(conn.assigns.current_user, params) do
      instructor = Backend.Repo.preload(instructor, :user)

      conn |> successful_response(%{instructor: instructor})
    else
      false ->
        conn |> forbidden_response()

      {:error, changeset} ->
        conn |> failed_changeset_response(changeset)
    end
  end

  def create_project(conn, params) do
    %{instructor: instructor} =
      user = Backend.Repo.preload(conn.assigns.current_user, :instructor)

    with true <- Backend.Instructors.authorize(:create_project, user),
         {:ok, project} <- Backend.Instructors.create_project(instructor, params) do
      conn |> successful_response(%{project: project})
    else
      false ->
        conn |> forbidden_response()

      {:error, changeset} ->
        conn |> failed_changeset_response(changeset)
    end
  end

  def update_project(conn, %{"project_id" => nil}) do
    conn |> bad_request_response("Project ID is required.")
  end

  def update_project(conn, params) do
    project = Backend.Instructors.find_project_by_id(params["project_id"])

    if is_nil(project) do
      conn |> not_found_response()
    else
      with true <-
             Backend.Instructors.authorize(:update_project, conn.assigns.current_user, %{
               project: project
             }),
           {:ok, project} <- Backend.Instructors.update_project(project, params) do
        conn |> successful_response(%{project: project})
      else
        false ->
          conn |> forbidden_response()

        {:error, changeset} ->
          conn |> failed_changeset_response(changeset)
      end
    end
  end

  def create_course(conn, params) do
    project = Backend.Instructors.find_project_by_id(params["project_id"])

    with true <-
           Backend.Instructors.authorize(:create_course, conn.assigns.current_user, %{
             project: project
           }),
         {:ok, course} <- Backend.Instructors.create_course(project, params) do
      course = Backend.Repo.preload(course, :project)
      conn |> successful_response(%{course: course})
    else
      false ->
        conn |> forbidden_response()

      {:error, changeset} ->
        conn |> failed_changeset_response(changeset)
    end
  end

  def update_course(conn, %{"course_id" => nil}) do
    conn |> bad_request_response("Course ID is required.")
  end

  def update_course(conn, params) do
    course = Backend.Instructors.find_course_by_id(params["course_id"])

    if is_nil(course) do
      conn |> not_found_response()
    else
      with true <-
             Backend.Instructors.authorize(:update_course, conn.assigns.current_user, %{
               course: course
             }),
           {:ok, course} <- Backend.Instructors.update_course(course, params) do
        course = Backend.Repo.preload(course, :project)

        conn |> successful_response(%{course: course})
      else
        false ->
          conn |> forbidden_response()

        {:error, changeset} ->
          conn |> failed_changeset_response(changeset)
      end
    end
  end

  def create_course_module(conn, %{"course_id" => nil}) do
    conn |> not_found_response("Course ID is required.")
  end

  def create_course_module(conn, params) do
    course = Backend.Instructors.find_course_by_id(params["course_id"])

    if is_nil(course) do
      conn |> not_found_response()
    else
      with true <-
             Backend.Instructors.authorize(:create_course_module, conn.assigns.current_user, %{
               course: course
             }),
           {:ok, module} <- Backend.Instructors.create_course_module(course, params) do
        module = Backend.Repo.preload(module, course: :project)

        conn |> successful_response(%{module: module})
      else
        false ->
          conn |> forbidden_response()

        {:error, changeset} ->
          conn |> failed_changeset_response(changeset)
      end
    end
  end

  def update_course_module(conn, %{"module_id" => nil}) do
    # dbg(conn)
    conn |> not_found_response("Course ID is required.")
  end

  def update_course_module(conn, params) do
    course_module = Backend.Instructors.find_course_module_by_id(params["module_id"])

    if is_nil(course_module) do
      conn |> not_found_response()
    else
      with true <-
             Backend.Instructors.authorize(:update_course_module, conn.assigns.current_user, %{
               course_module: course_module
             }),
           {:ok, course_module} <- Backend.Instructors.update_course_module(course_module, params) do
        course_module = Backend.Repo.preload(course_module, :course)

        conn |> successful_response(%{course_module: course_module})
      else
        false ->
          conn |> forbidden_response()

        {:error, changeset} ->
          conn |> failed_changeset_response(changeset)
      end
    end
  end

  def create_course_lesson(conn, %{"module_id" => nil}) do
    conn |> not_found_response("Module ID is required.")
  end

  def create_course_lesson(conn, params) do
    course_module = Backend.Instructors.find_course_module_by_id(params["module_id"])

    if is_nil(course_module) do
      conn |> not_found_response()
    else
      with true <-
             Backend.Instructors.authorize(:create_course_lesson, conn.assigns.current_user, %{
               course_module: course_module
             }),
           {:ok, lesson} <- Backend.Instructors.create_course_lesson(course_module, params) do
        lesson =
          lesson
          |> Backend.Repo.preload([:text_details, :video_details, module: [course: :project]])

        conn |> successful_response(%{lesson: lesson})
      else
        false ->
          conn |> forbidden_response()

        {:error, changeset} ->
          conn |> failed_changeset_response(changeset)
      end
    end
  end

  def update_course_lesson(conn, %{"lesson_id" => nil}) do
    conn |> not_found_response("Lesson ID is required.")
  end

  def update_course_lesson(conn, params) do
    lesson = Backend.Instructors.find_course_lesson_by_id(params["lesson_id"])

    if is_nil(lesson) do
      conn |> not_found_response()
    else
      with true <-
             Backend.Instructors.authorize(:update_course_lesson, conn.assigns.current_user, %{
               course_lesson: lesson
             }),
           {:ok, lesson} <- Backend.Instructors.update_course_lesson(lesson, params) do
        lesson =
          lesson
          |> Backend.Repo.preload([:text_details, :video_details, module: [course: :project]])

        conn |> successful_response(%{lesson: lesson})
      else
        false ->
          conn |> forbidden_response()

        {:error, changeset} ->
          conn |> failed_changeset_response(changeset)
      end
    end
  end

  def delete_course_lesson(conn, %{"lesson_id" => nil}) do
    conn |> not_found_response("Lesson ID is required.")
  end

  def delete_course_lesson(conn, params) do
    lesson = Backend.Instructors.find_course_lesson_by_id(params["lesson_id"])

    if is_nil(lesson) do
      conn |> not_found_response()
    else
      with true <-
             Backend.Instructors.authorize(:delete_course_lesson, conn.assigns.current_user, %{
               course_lesson: lesson
             }),
           {:ok, lesson} <- Backend.Instructors.delete_course_lesson(lesson) do
        lesson =
          lesson
          |> Backend.Repo.preload([:text_details, :video_details, module: [course: :project]])

        conn |> successful_response(%{lesson: lesson})
      else
        false ->
          conn |> forbidden_response()

        {:error, changeset} ->
          conn |> failed_changeset_response(changeset)
      end
    end
  end

  def publish_course(conn, %{"course_id" => nil}) do
    conn |> not_found_response("Course ID is required.")
  end

  def publish_course(conn, params) do
    course = Backend.Instructors.find_course_by_id(params["course_id"])

    if is_nil(course) do
      conn |> not_found_response()
    else
      with true <-
             Backend.Instructors.authorize(:publish_course, conn.assigns.current_user, %{
               course: course
             }),
           {:ok, course} <- Backend.Instructors.publish_course(course, params) do
        course = Backend.Repo.preload(course, :project)

        conn |> successful_response(%{course: course})
      else
        false ->
          conn |> forbidden_response()

        {:error, changeset} ->
          conn |> failed_changeset_response(changeset)
      end
    end
  end
end
