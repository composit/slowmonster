defmodule SlowmonsterWeb.Router do
  use SlowmonsterWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SlowmonsterWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", SlowmonsterWeb do
    pipe_through :api

    resources "/users", UserController, only: [:create, :show]
    resources "/sessions", SessionController, only: [:create]
    resources "/tickets", TicketController, only: [:index, :create, :show]
    resources "/times", TimeController, only: [:index, :create, :show, :update, :delete]
    resources "/amounts", AmountController, only: [:index, :create, :show, :update, :delete]
    resources "/reports", ReportController, only: [:index]
  end
end
