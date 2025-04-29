defmodule Backend.Instructors.Policy do
  @behaviour Bodyguard.Policy

  def authorize(action, user), do: authorize(action, user, [])

  def authorize(:create_instructor, _user, _params), do: true

  def authorize(:create_project, _user, _params), do: true

  def authorize(:update_project, user, %{project: project} = _params) do
    project = Backend.Repo.preload(project, :instructor)

    user.id == project.instructor.user_id
  end

  def authorize(:create_course, user, %{project: project} = _params) do
    project = Backend.Repo.preload(project, :instructor)

    user.id == project.instructor.user_id
  end

  def authorize(action, user, %{course: course} = _params)
      when action in [
             :update_course,
             :publish_course
           ] do
    course = Backend.Repo.preload(course, project: [:instructor])

    user.id == course.project.instructor.user_id
  end

  def authorize(:create_course_module, user, %{course: course} = _params) do
    course = Backend.Repo.preload(course, project: [:instructor])

    user.id == course.project.instructor.user_id
  end

  def authorize(action, user, %{course_module: course_module} = _params)
      when action in [:update_course_module, :create_course_lesson] do
    course_module = Backend.Repo.preload(course_module, course: [project: :instructor])

    user.id == course_module.course.project.instructor.user_id
  end

  def authorize(action, user, %{course_lesson: course_lesson} = _params)
      when action in [
             :update_course_lesson,
             :delete_course_lesson,
             :upload_course_lesson_video,
             :delete_course_lesson_video
           ] do
    course_lesson = Backend.Repo.preload(course_lesson, module: [course: [project: :instructor]])

    user.id == course_lesson.module.course.project.instructor.user_id
  end
end
