defmodule Backend.Instructors.InstructorProjectStatus do
  use EctoEnum,
    type: :instructor_project_status,
    enums: [
      :draft,
      :published,
      :archived
    ]
end
