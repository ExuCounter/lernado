defmodule Backend.Instructors.Queries do
  import Ecto.Query

  def get_next_course_module_order_index(course) do
    query =
      from(modules in Backend.Instructors.Schema.Course.Module,
        where: modules.course_id == ^course.id,
        select: modules.order
      )

    order_indexes = Backend.Repo.all(query)

    if Enum.empty?(order_indexes) do
      0
    else
      Enum.max(order_indexes) + 1
    end
  end

  def get_next_course_lesson_order_index(module) do
    query =
      from(m in Backend.Instructors.Schema.Course.Lesson,
        where: m.id == ^module.id,
        select: m.order_index
      )

    order_indexes = Backend.Repo.all(query)

    if Enum.empty?(order_indexes) do
      0
    else
      Enum.max(order_indexes) + 1
    end
  end
end
