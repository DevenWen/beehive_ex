defmodule BeeAdminWeb.Router do
  use BeeAdminWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BeeAdminWeb do
    pipe_through :api
    get "/health", ApiController, :health_check
  end
end
