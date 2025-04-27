defmodule Backend.Instructors.InstructorProjectStatus do
  use EctoEnum,
    type: :project_status,
    enums: [
      :draft,
      :published,
      :archived
    ]
end
