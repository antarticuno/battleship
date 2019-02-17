defmodule BattleshipWeb.SessionController do

  use BattleshipWeb, :controller

  # TODO might have to how the redirects work
  def create(conn, %{"name" => name, "player_name" => player_name}) do
    conn
    |> put_session(:player_name, player_name)
    |> put_session(:name, name)
    |> put_flash(:info, "Joined #{name} as #{player_name}")
    |> redirect(to: Routes.page_path(conn, :game, name, %{player_name: player_name}))
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:player_name)
    |> delete_session(:name)
    |> put_flash(:info, "Left game.")
    |> redirect(to: Routes.page_path(conn, :index))
  end

end
