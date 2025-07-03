defmodule Backend.Instructors.Policy do
  @behaviour Bodyguard.Policy

  def authorize(:create_instructor, _user, %{session_role: session_role}),
    do: session_role === :pending

  def authorize(:create_project, _user, %{session_role: session_role}),
    do: session_role === :instructor

  def authorize(:update_project, user, %{project: project, session_role: session_role}) do
    project = Backend.Repo.preload(project, :instructor)

    session_role === :instructor and user.id == project.instructor.user_id
  end

  def authorize(:create_course, user, %{project: project, session_role: session_role}) do
    project = Backend.Repo.preload(project, :instructor)

    session_role === :instructor and user.id == project.instructor.user_id
  end

  def authorize(action, user, %{course: course, session_role: session_role} = _params)
      when action in [
             :update_course,
             :publish_course
           ] do
    course = Backend.Repo.preload(course, project: [:instructor])

    session_role === :instructor and user.id == course.project.instructor.user_id
  end

  def authorize(:create_course_module, user, %{course: course, session_role: session_role}) do
    course = Backend.Repo.preload(course, project: [:instructor])

    session_role === :instructor and user.id == course.project.instructor.user_id
  end

  def authorize(action, user, %{course_module: course_module, session_role: session_role})
      when action in [:update_course_module, :create_course_lesson] do
    course_module = Backend.Repo.preload(course_module, course: [project: :instructor])

    session_role === :instructor and user.id == course_module.course.project.instructor.user_id
  end

  def authorize(
        action,
        user,
        %{course_lesson: course_lesson, session_role: session_role}
      )
      when action in [
             :update_course_lesson,
             :delete_course_lesson,
             :upload_course_lesson_video,
             :delete_course_lesson_video
           ] do
    course_lesson = Backend.Repo.preload(course_lesson, module: [course: [project: :instructor]])

    session_role === :instructor and
      user.id == course_lesson.module.course.project.instructor.user_id
  end
end
