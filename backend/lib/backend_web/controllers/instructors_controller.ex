defmodule BackendWeb.InstructorsController do
  use BackendWeb, :controller
  action_fallback BackendWeb.FallbackController

  def create_instructor(conn, _params) do
    %{current_user: current_user, session_role: session_role} = conn.assigns

    with :ok <-
           Bodyguard.permit(Backend.Instructors, :create_instructor, current_user, %{
             session_role: session_role
           }),
         {:ok, user} <-
           Backend.Instructors.create_instructor(current_user) do
      conn
      |> put_status(200)
      |> json(%{
        data: %{
          instructor: user.instructor
        }
      })
    end
  end

  def create_project(conn, params) do
    %{current_user: current_user, session_role: session_role} = conn.assigns

    %{instructor: instructor} = Backend.Repo.preload(current_user, :instructor)

    with :ok <-
           Bodyguard.permit(Backend.Instructors, :create_project, current_user, %{
             session_role: session_role
           }),
         {:ok, project} <- Backend.Instructors.create_project(instructor, params) do
      conn
      |> put_status(200)
      |> json(%{
        data: %{
          project: project
        }
      })
    end
  end

  def update_project(conn, params) do
    %{current_user: current_user, session_role: session_role} = conn.assigns

    with {:ok, project} <- Backend.Instructors.find_project_by_id(params["project_id"]),
         :ok <-
           Bodyguard.permit(Backend.Instructors, :update_project, current_user, %{
             project: project,
             session_role: session_role
           }),
         {:ok, project} <- Backend.Instructors.update_project(project, params) do
      conn
      |> put_status(200)
      |> json(%{
        data: %{
          project: project
        }
      })
    end
  end

  def create_course(conn, params) do
    %{current_user: current_user, session_role: session_role} = conn.assigns

    with {:ok, project} <- Backend.Instructors.find_project_by_id(params["project_id"]),
         :ok <-
           Bodyguard.permit(Backend.Instructors, :create_course, current_user, %{
             project: project,
             session_role: session_role
           }),
         {:ok, course} <- Backend.Instructors.create_course(project, params) do
      course = Backend.Repo.preload(course, :project)

      conn
      |> put_status(200)
      |> json(%{
        data: %{
          course: course
        }
      })
    end
  end

  def update_course(conn, params) do
    %{current_user: current_user, session_role: session_role} = conn.assigns

    with {:ok, course} <- Backend.Instructors.find_course_by_id(params["course_id"]),
         :ok <-
           Bodyguard.permit(Backend.Instructors, :update_course, current_user, %{
             course: course,
             session_role: session_role
           }),
         {:ok, course} <- Backend.Instructors.update_course(course, params) do
      course = Backend.Repo.preload(course, :project)

      conn
      |> put_status(200)
      |> json(%{
        data: %{
          course: course
        }
      })
    end
  end

  def create_course_module(conn, params) do
    %{current_user: current_user, session_role: session_role} = conn.assigns

    with {:ok, course} <- Backend.Instructors.find_course_by_id(params["course_id"]),
         :ok <-
           Bodyguard.permit(
             Backend.Instructors,
             :create_course_module,
             current_user,
             %{
               course: course,
               session_role: session_role
             }
           ),
         {:ok, module} <- Backend.Instructors.create_course_module(course, params) do
      module = Backend.Repo.preload(module, course: :project)

      conn
      |> put_status(200)
      |> json(%{
        data: %{
          module: module
        }
      })
    end
  end

  def update_course_module(conn, params) do
    %{current_user: current_user, session_role: session_role} = conn.assigns

    with {:ok, course_module} <-
           Backend.Instructors.find_course_module_by_id(params["module_id"]),
         :ok <-
           Bodyguard.permit(
             Backend.Instructors,
             :update_course_module,
             current_user,
             %{
               course_module: course_module,
               session_role: session_role
             }
           ),
         {:ok, course_module} <- Backend.Instructors.update_course_module(course_module, params) do
      course_module = Backend.Repo.preload(course_module, :course)

      conn
      |> put_status(200)
      |> json(%{
        data: %{
          module: course_module
        }
      })
    end
  end

  def create_course_lesson(conn, params) do
    %{current_user: current_user, session_role: session_role} = conn.assigns

    with {:ok, course_module} <-
           Backend.Instructors.find_course_module_by_id(params["module_id"]),
         :ok <-
           Bodyguard.permit(
             Backend.Instructors,
             :create_course_lesson,
             current_user,
             %{
               course_module: course_module,
               session_role: session_role
             }
           ),
         {:ok, lesson} <- Backend.Instructors.create_course_lesson(course_module, params) do
      lesson =
        lesson
        |> Backend.Repo.preload([:text_details, :video_details, module: [course: :project]])

      conn
      |> put_status(200)
      |> json(%{
        data: %{
          lesson: lesson
        }
      })
    end
  end

  def update_course_lesson(conn, params) do
    %{current_user: current_user, session_role: session_role} = conn.assigns

    with {:ok, lesson} <- Backend.Instructors.find_course_lesson_by_id(params["lesson_id"]),
         :ok <-
           Bodyguard.permit(
             Backend.Instructors,
             :update_course_lesson,
             current_user,
             %{
               course_lesson: lesson,
               session_role: session_role
             }
           ),
         {:ok, lesson} <- Backend.Instructors.update_course_lesson(lesson, params) do
      lesson =
        lesson
        |> Backend.Repo.preload([:text_details, :video_details, module: [course: :project]])

      conn
      |> put_status(200)
      |> json(%{
        data: %{
          lesson: lesson
        }
      })
    end
  end

  def upload_course_lesson_video(conn, params) do
    %{current_user: current_user, session_role: session_role} = conn.assigns

    with {:ok, lesson} <- Backend.Instructors.find_course_lesson_by_id(params["lesson_id"]),
         :ok <-
           Bodyguard.permit(
             Backend.Instructors,
             :upload_course_lesson_video,
             current_user,
             %{
               course_lesson: lesson,
               session_role: session_role
             }
           ),
         {:ok, lesson} <-
           Backend.Instructors.upload_course_lesson_video(lesson, params["video"]) do
      lesson =
        lesson
        |> Backend.Repo.preload([:text_details, :video_details, module: [course: :project]])

      conn
      |> put_status(200)
      |> json(%{
        data: %{
          lesson: lesson
        }
      })
    end
  end

  def delete_course_lesson_video(conn, params) do
    %{current_user: current_user, session_role: session_role} = conn.assigns

    with {:ok, lesson} <- Backend.Instructors.find_course_lesson_by_id(params["lesson_id"]),
         :ok <-
           Bodyguard.permit(
             Backend.Instructors,
             :delete_course_lesson_video,
             current_user,
             %{
               course_lesson: lesson,
               session_role: session_role
             }
           ),
         {:ok, lesson} <-
           Backend.Instructors.delete_course_lesson_video(lesson) do
      lesson =
        lesson
        |> Backend.Repo.preload([:text_details, :video_details, module: [course: :project]])

      conn
      |> put_status(200)
      |> json(%{
        data: %{
          lesson: lesson
        }
      })
    end
  end

  def delete_course_lesson(conn, params) do
    %{current_user: current_user, session_role: session_role} = conn.assigns

    with {:ok, lesson} <- Backend.Instructors.find_course_lesson_by_id(params["lesson_id"]),
         :ok <-
           Bodyguard.permit(
             Backend.Instructors,
             :delete_course_lesson,
             current_user,
             %{
               course_lesson: lesson,
               session_role: session_role
             }
           ),
         {:ok, lesson} <- Backend.Instructors.delete_course_lesson(lesson) do
      lesson =
        lesson
        |> Backend.Repo.preload([:text_details, :video_details, module: [course: :project]])

      conn
      |> put_status(200)
      |> json(%{
        data: %{
          lesson: lesson
        }
      })
    end
  end

  def publish_course(conn, params) do
    %{current_user: current_user, session_role: session_role} = conn.assigns

    with {:ok, course} <- Backend.Instructors.find_course_by_id(params["course_id"]),
         :ok <-
           Bodyguard.permit(Backend.Instructors, :publish_course, current_user, %{
             course: course,
             session_role: session_role
           }),
         {:ok, course} <- Backend.Instructors.publish_course(course) do
      course = Backend.Repo.preload(course, :project)

      conn
      |> put_status(200)
      |> json(%{
        data: %{
          course: course
        }
      })
    end
  end
end
