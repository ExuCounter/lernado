defmodule Backend.Instructors.Policy do
  @behaviour Bodyguard.Policy

  def authorize(:create_instructor, _user), do: true

  def authorize(:create_project, _user), do: true

  def authorize(:update_project, user, %{project: project} = _params) do
    project = Backend.Repo.preload(project, :instructor)

    user.id == project.instructor.user_id
  end

  def authorize(:create_course, user, %{project: project} = _params) do
    project = Backend.Repo.preload(project, :instructor)

    user.id == project.instructor.user_id
  end

  def authorize(:update_course, user, %{course: course} = _params) do
    course = Backend.Repo.preload(course, project: [:instructor])

    user.id == course.project.instructor.user_id
  end

  def authorize(:create_course_module, user, %{course: course} = _params) do
    course = Backend.Repo.preload(course, project: [:instructor])

    user.id == course.project.instructor.user_id
  end

  def authorize(:update_course_module, user, %{course_module: course_module} = _params) do
    course_module = Backend.Repo.preload(course_module, course: [project: :instructor])

    user.id == course_module.course.project.instructor.user_id
  end
end
