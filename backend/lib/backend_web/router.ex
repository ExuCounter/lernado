defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {BackendWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug BackendWeb.Plugs.EnsureAuthenticated
  end

  pipeline :auth do
    plug(:accepts, ["html"])
    plug(:fetch_session)
  end

  # scope "/", BackendWeb do
  #   pipe_through(:browser)

  #   get("/", PageController, :home)
  # end

  scope "/api", BackendWeb do
    pipe_through(:api)

    scope "/users" do
      put("/update", UsersController, :update)
      get("/:user_id", UsersController, :find)
    end

    scope "/instructors" do
      put("/create", InstructorsController, :create_instructor)

      scope "/projects" do
        put("/create", InstructorsController, :create_project)
        put("/update", InstructorsController, :update_project)
      end

      scope "/courses" do
        put("/create", InstructorsController, :create_course)
        put("/update", InstructorsController, :update_course)

        scope "/modules" do
          put("/create", InstructorsController, :create_course_module)
          put("/update", InstructorsController, :update_course_module)
        end
      end
    end
  end

  scope "/auth", BackendWeb do
    pipe_through(:auth)

    post("/login", AuthController, :login)
    post("/register", AuthController, :register)
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:backend, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: BackendWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
