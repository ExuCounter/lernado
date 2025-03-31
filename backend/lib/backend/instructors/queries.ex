defmodule Backend.Instructors.Queries do
  import Ecto.Query

  def get_next_course_module_order(course) do
    query =
      from(modules in Backend.Instructors.Schema.Course.Module,
        where: modules.course_id == ^course.id,
        select: modules.order
      )

    orders = Backend.Repo.all(query)

    if Enum.empty?(orders) do
      0
    else
      Enum.max(orders) + 1
    end
  end
end
