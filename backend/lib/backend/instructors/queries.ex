defmodule Backend.Instructors.Queries do
  import Ecto.Query

  def get_current_highest_order_index_for_course_module(course) do
    from(modules in Backend.Instructors.Schema.Course.Module,
      where: modules.course_id == ^course.id,
      order_by: [desc: modules.order_index],
      limit: 1,
      select: modules.order_index
    )
  end

  def get_current_highest_order_index_for_course_lesson(module) do
    from(lessons in Backend.Instructors.Schema.Course.Lesson,
      where: lessons.module_id == ^module.id,
      order_by: [desc: lessons.order_index],
      limit: 1,
      select: lessons.order_index
    )
  end
end
