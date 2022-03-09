defmodule ChatterWeb.Router do
  use ChatterWeb, :router
  alias ChatterWeb.Plugs

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ChatterWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Doorman.Login.Session
    # plug :put_user_email
    plug Plugs.PutUserEmail
  end

  # defp put_user_email(conn, _) do
  #   # IO.inspect(conn, label: "conn")

  #   if current_user = conn.assigns[:current_user] do
  #     assign(conn, :email, current_user.email)
  #   else
  #     conn
  #   end
  # end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChatterWeb do
    pipe_through :browser

    get "/sign_in", SessionController, :new
    resources "/sessions", SessionController, only: [:create, :delete]
    resources "/users", UserController, only: [:new, :create]
  end

  scope "/", ChatterWeb do
    # pipe_through :browser
    pipe_through [:browser, Plugs.RequireLogin]

    resources "/chat_rooms", ChatRoomController, only: [:new, :create, :show]
    # get "/", PageController, :index
    get "/", ChatRoomController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChatterWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ChatterWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
