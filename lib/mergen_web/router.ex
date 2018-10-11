defmodule MergenWeb.Router do
  @moduledoc false
  use MergenWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", MergenWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/lessons", PageController, :lessons)
    get("/reviews", PageController, :reviews)

    resources("/items", ItemController)
  end

  # Other scopes may use custom stacks.
  # scope "/api", MergenWeb do
  #   pipe_through :api
  # end
end
