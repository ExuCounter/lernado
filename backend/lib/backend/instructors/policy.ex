defmodule Backend.Instructors.Policy do
  @behaviour Bodyguard.Policy

  def authorize(:create_instructor, _user), do: true
  def authorize(:create_project, _user), do: true

  def authorize(:update_project, user, %{project: project} = _params) do
    project = Backend.Repo.preload(project, :instructor)

    user.id == project.instructor.user_id
  end
end
