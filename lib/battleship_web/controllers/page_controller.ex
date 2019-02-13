defmodule BattleshipWeb.PageController do
  use BattleshipWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def redirect_to_index(conn, _params) do
    redirect(conn, to: "/")
  end

  def game(conn, %{"name" => name}) do
    render conn, "game.html", name: name
  end

  def make_game(conn, %{"name" => name}) do
    redirect(conn, to: "/game/" <> name)
  end  
end
