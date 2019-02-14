defmodule BattleshipWeb.GamesChannel do
  use BattleshipWeb, :channel

  alias Battleship.Game
  alias Battleship.BackupAgent

  def join("games:" <> game_name, payload, socket) do
    player_name = Map.get(payload, "player_name")

    if authorized?(game_name, player_name) do
      game = BackupAgent.get(game_name) || Game.new()
      socket = socket
      |> assign(:game, game)
      |> assign(:name, game_name)
      BackupAgent.put(game_name, game)
      {:ok, %{"join" => game_name, "game" => Game.client_view(game, player_name)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  #TODO fill out these handle_ins
  def handle_in("new", _payload, socket) do
    
  end

  def handle_in("sting", payload, socket) do
    name = socket.assigns[:name]
    game = GameServer.guess()
    player_name = "TODO"
    {:reply, {:waiting, %{"game" => Game.client_view(game, player_name)}}, socket}
  end

  def handle_in("place", payload, socket) do

  end

  defp update_state(socket, game) do
     name = socket.assigns[:name]
     socket = assign(socket, :game, game)
     BackupAgent.put(name, game)
     {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
   end

  defp authorized?(game_name, player_name) do
    # TODO check if player name trying to get into the right game
    # ie: game is not full OR player is already in that game and re-connecting
    true
  end
end
