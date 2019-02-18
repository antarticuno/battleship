defmodule BattleshipWeb.PageController do
  use BattleshipWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def redirect_to_index(conn, _params) do
    redirect(conn, to: "/")
  end

  # def observe(conn), do: render conn, "game.html", %{name: name, player_name: nil}

  def game(conn, _name), do: render conn, "game.html"

  def join_game(conn, %{"name" => name, "player_name" => player_name}) do
    redirect(conn, to: "/game/" <> name <> "/" <> player_name)
  end  
end
