defmodule Backend.Instructors do
  defdelegate authorize(action, user, params), to: Backend.Instructors.Policy
  defdelegate authorize(action, user), to: Backend.Instructors.Policy

  def create_instructor(user) do
    user |> Backend.Instructors.Schema.Instructor.create_changeset() |> Backend.Repo.insert()
  end

  def create_instructor!(user) do
    user |> Backend.Instructors.Schema.Instructor.create_changeset() |> Backend.Repo.insert!()
  end

  def create_project(instructor, attrs) do
    instructor
    |> Backend.Instructors.Schema.Project.create_changeset(attrs)
    |> Backend.Repo.insert()
  end

  def create_project!(instructor, attrs) do
    instructor
    |> Backend.Instructors.Schema.Project.create_changeset(attrs)
    |> Backend.Repo.insert!()
  end

  def update_project(project, attrs) do
    project
    |> Backend.Instructors.Schema.Project.update_changeset(attrs)
    |> Backend.Repo.update()
  end

  def create_course(project, attrs) do
    project
    |> Backend.Instructors.Schema.Course.create_changeset(attrs)
    |> Backend.Repo.insert()
  end

  def create_course!(project, attrs) do
    project |> Backend.Instructors.Schema.Course.create_changeset(attrs) |> Backend.Repo.insert!()
  end

  def update_course(course, attrs) do
    course
    |> Backend.Instructors.Schema.Course.update_changeset(attrs)
    |> Backend.Repo.update()
  end

  def update_course!(course, attrs) do
    course
    |> Backend.Instructors.Schema.Course.update_changeset(attrs)
    |> Backend.Repo.update!()
  end

  def publish_course(course) do
    course
    |> Backend.Instructors.Schema.Course.publish_changeset()
    |> Backend.Repo.update()
  end

  def publish_course!(course) do
    course
    |> Backend.Instructors.Schema.Course.publish_changeset()
    |> Backend.Repo.update!()
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

  def find_project_by_id(id) do
    Backend.Repo.find_by_id(Backend.Instructors.Schema.Project, id)
  end

  def find_course_by_id(id) do
    Backend.Repo.find_by_id(Backend.Instructors.Schema.Course, id)
  end

  def find_course_module_by_id(id) do
    Backend.Repo.find_by_id(Backend.Instructors.Schema.Course.Module, id)
  end

  def find_course_lesson_by_id(id) do
    Backend.Repo.find_by_id(Backend.Instructors.Schema.Course.Lesson, id)
  end

  def get_next_course_module_order_index(course) do
    max_order_index = course |> Ecto.assoc(:modules) |> Backend.Repo.aggregate(:max, :order_index)

    case max_order_index do
      nil -> 0
      _ -> max_order_index + 1
    end
  end

  def get_next_course_lesson_order_index(module) do
    max_order_index = module |> Ecto.assoc(:lessons) |> Backend.Repo.aggregate(:max, :order_index)

    case max_order_index do
      nil -> 0
      _ -> max_order_index + 1
    end
  end

  def create_course_lesson(module, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :lesson,
      Backend.Instructors.Schema.Course.Lesson.create_changeset(module, attrs)
    )
    |> Ecto.Multi.insert(:lesson_by_type, fn %{lesson: lesson} ->
      case lesson.type do
        :video -> Backend.Instructors.Schema.Course.Lesson.Video.create_changeset(lesson, attrs)
        :text -> Backend.Instructors.Schema.Course.Lesson.Text.create_changeset(lesson, attrs)
      end
    end)
    |> Backend.Repo.transaction()
    |> case do
      {:ok, %{lesson: lesson}} -> {:ok, lesson}
      {:error, :lesson, changeset, _changes} -> {:error, changeset}
    end
  end

  def delete_course_lesson(lesson) do
    Backend.Repo.delete(lesson)
  end

  @lesson_details_mapper %{
    video: Backend.Instructors.Schema.Course.Lesson.Video,
    text: Backend.Instructors.Schema.Course.Lesson.Text
  }

  def update_course_lesson(lesson, attrs) do
    current_lesson_type = lesson.type

    incoming_lesson_type =
      if is_binary(attrs["type"]) do
        String.to_existing_atom(attrs["type"])
      else
        current_lesson_type
      end

    lesson_type_changed? = current_lesson_type != incoming_lesson_type

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.update(
        :lesson,
        Backend.Instructors.Schema.Course.Lesson.update_changeset(lesson, attrs)
      )

    if lesson_type_changed? do
      multi
      |> Ecto.Multi.delete(:delete_lesson_details, fn %{lesson: lesson} ->
        @lesson_details_mapper[current_lesson_type].get_by_lesson_id(lesson.id)
      end)
      |> Ecto.Multi.insert(:create_lesson_details, fn %{lesson: lesson} ->
        @lesson_details_mapper[incoming_lesson_type].create_changeset(lesson, attrs)
      end)
      |> Backend.Repo.transaction()
      |> case do
        {:ok, %{lesson: lesson}} -> {:ok, lesson}
        {:error, _, changeset, _changes} -> {:error, changeset}
      end
    else
      multi
      |> Ecto.Multi.update(:update_lesson_details, fn %{lesson: lesson} ->
        lesson_details_struct = @lesson_details_mapper[current_lesson_type]
        lesson_details = lesson_details_struct.get_by_lesson_id(lesson.id)

        lesson_details |> lesson_details_struct.update_changeset(attrs)
      end)
      |> Backend.Repo.transaction()
      |> case do
        {:ok, %{lesson: lesson}} -> {:ok, lesson |> Backend.Repo.reload()}
        {:error, _, changeset, _changes} -> {:error, changeset}
      end
    end
  end

  def upload_course_lesson_video(lesson, %{path: path, filename: filename} = _params) do
    with {:ok, video_url} <-
           Backend.AWS.Courses.upload_file(lesson.course_id, path, filename),
         {:ok, lesson} <- update_course_lesson(lesson, %{video_url: video_url}) do
      {:ok, lesson}
    end
  end

  def delete_course_lesson_video(lesson) do
    lesson = Backend.Repo.preload(lesson, :video_details)
    filename = lesson.video_details.video_url |> Path.basename()

    with {:ok, :deleted} <-
           Backend.AWS.Courses.delete_file(
             lesson.course_id,
             filename
           ),
         {:ok, lesson} <- update_course_lesson(lesson, %{video_url: nil}) do
      {:ok, lesson}
    end
  end

  def create_payment_integration(instructor, params) do
    instructor
    |> Backend.Instructors.Schema.PaymentIntegration.create_changeset(params)
    |> Backend.Repo.insert()
  end

  def create_payment_integration!(instructor, params) do
    instructor
    |> Backend.Instructors.Schema.PaymentIntegration.create_changeset(params)
    |> Backend.Repo.insert!()
  end

  def attach_payment_integration_to_course(course, integration) do
    course
    |> Backend.Instructors.Schema.Course.update_payment_integration_changeset(integration)
    |> Backend.Repo.update()
  end

  def attach_payment_integration_to_course!(course, integration) do
    course
    |> Backend.Instructors.Schema.Course.update_payment_integration_changeset(integration)
    |> Backend.Repo.update!()
  end

  def ensure_course_published(course) do
    if course.status == :published do
      :ok
    else
      {:error, %{message: "Course is not published", status: :bad_request}}
    end
  end
end
