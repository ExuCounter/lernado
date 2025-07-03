defmodule BackendWeb.SeedFactorySchema do
  use SeedFactory.Schema
  include_schema(Backend.SeedFactorySchema)

  command :build_conn do
    resolve(fn _ ->
      conn = Phoenix.ConnTest.build_conn()

      {:ok, %{conn: conn}}
    end)

    produce(:conn)
  end

  command :create_pending_user_session do
    param(:user, entity: :user)
    param(:conn, entity: :conn, with_traits: [:unauthenticated])

    resolve(fn args ->
      {:ok,
       %{
         conn:
           BackendWeb.SessionHelpers.init_user_session(args.conn, args.user, %{
             session_role: :pending
           })
       }}
    end)

    update(:conn)
  end

  command :create_student_user_session do
    param(:user, entity: :user)
    param(:student, entity: :student)
    param(:conn, entity: :conn, with_traits: [:unauthenticated])

    resolve(fn args ->
      {:ok,
       %{
         conn:
           BackendWeb.SessionHelpers.init_user_session(args.conn, args.user, %{
             session_role: :student
           })
       }}
    end)

    update(:conn)
  end

  command :create_instructor_user_session do
    param(:user, entity: :user)
    param(:instructor, entity: :instructor)
    param(:conn, entity: :conn, with_traits: [:unauthenticated])

    resolve(fn args ->
      {:ok,
       %{
         conn:
           BackendWeb.SessionHelpers.init_user_session(args.conn, args.user, %{
             session_role: :instructor
           })
       }}
    end)

    update(:conn)
  end

  trait :pending_user_session, :conn do
    from(:unauthenticated)
    exec(:create_pending_user_session)
  end

  trait :student_user_session, :conn do
    from(:unauthenticated)
    exec(:create_student_user_session)
  end

  trait :instructor_user_session, :conn do
    from(:unauthenticated)
    exec(:create_instructor_user_session)
  end

  trait :unauthenticated, :conn do
    exec(:build_conn)
  end
end
