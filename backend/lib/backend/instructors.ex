defmodule Backend.Instructors do
  defdelegate authorize(action, user, params), to: Backend.Instructors.Policy
  defdelegate authorize(action, user), to: Backend.Instructors.Policy

  def create_instructor(user, attrs) do
    user |> Backend.Instructors.Schema.Instructor.create_changeset(attrs) |> Backend.Repo.insert()
  end

  def create_project(instructor, attrs) do
    instructor
    |> Backend.Instructors.Schema.Project.create_changeset(attrs)
    |> Backend.Repo.insert()
  end

  def update_project(project, attrs) do
    project
    |> Backend.Instructors.Schema.Project.update_changeset(attrs)
    |> Backend.Repo.update()
  end

  def create_course(project, attrs) do
    project |> Backend.Instructors.Schema.Course.create_changeset(attrs) |> Backend.Repo.insert()
  end

  def update_course(course, attrs) do
    course
    |> Backend.Instructors.Schema.Course.update_changeset(attrs)
    |> Backend.Repo.update()
  end

  def create_course_module(course, attrs) do
    course
    |> Backend.Instructors.Schema.Course.Module.create_changeset(attrs)
    |> Backend.Repo.insert()
  end

  def update_course_module(module, attrs) do
    module
    |> Backend.Instructors.Schema.Course.Module.update_changeset(attrs)
    |> Backend.Repo.insert()
  end

  def find_instructor_by_id(id) do
    Backend.Repo.get_by(Backend.Instructors.Schema.Instructor, id: id)
  end

  def find_project_by_id(id) do
    Backend.Repo.get_by(Backend.Instructors.Schema.Project, id: id)
  end

  def find_course_by_id(id) do
    Backend.Repo.get_by(Backend.Instructors.Schema.Course, id: id)
  end

  def find_course_module_by_id(id) do
    Backend.Repo.get_by(Backend.Instructors.Schema.Course.Module, id: id)
  end
end
