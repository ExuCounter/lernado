defmodule Backend.Instructors.Course.Lesson.Type do
  use EctoEnum,
    type: :instructor_course_lesson_type,
    enums: [
      :text,
      :video
    ]
end
