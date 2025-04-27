ExUnit.start()
Faker.start()
Ecto.Adapters.SQL.Sandbox.mode(Backend.Repo, :manual)

Mox.defmock(Backend.AWS.DispatcherMock, for: Backend.AWS.Dispatcher)

Application.put_env(:backend, :aws,
  dispatcher: Backend.AWS.DispatcherMock,
  courses_bucket: "courses_dummy_bucket"
)
