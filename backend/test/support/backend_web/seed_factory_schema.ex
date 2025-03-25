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

  command :create_user_session do
    param(:user, entity: :user)
    param(:conn, entity: :conn, with_traits: [:unauthenticated])

    resolve(fn args ->
      {:ok, %{conn: BackendWeb.SessionHelpers.init_user_session(args.conn, args.user)}}
    end)

    update(:conn)
  end

  trait :user_session, :conn do
    from(:unauthenticated)
    exec(:create_user_session)
  end

  trait :unauthenticated, :conn do
    exec(:build_conn)
  end
end
