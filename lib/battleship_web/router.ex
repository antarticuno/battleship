defmodule BattleshipWeb.Router do
  use BattleshipWeb, :router

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

  scope "/", BattleshipWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/game", PageController, :redirect_to_index
    get "/game/:name", PageController, :game
    post "/game", PageController, :make_game
  end

  # Other scopes may use custom stacks.
  # scope "/api", BattleshipWeb do
  #   pipe_through :api
  # end
end
