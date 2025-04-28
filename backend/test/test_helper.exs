Mox.defmock(Backend.AWS.DispatcherMock, for: Backend.AWS.Dispatcher)

ExUnit.start()
Faker.start()
Ecto.Adapters.SQL.Sandbox.mode(Backend.Repo, :manual)
