defmodule BattleshipWeb.GamesChannel do
  use BattleshipWeb, :channel

  alias Battleship.Game
  alias Battleship.BackupAgent
  alias Battleship.GameServer

  def join("games:" <> game_name, payload, socket) do
    player_name = Map.get(payload, "player_name")
    game = BackupAgent.get(game_name) || Game.new()
  
    if authorized?(game_name, player_name) do
      game = Game.add_player(game, player_name)

      socket = socket
      |> assign(:game_name, game_name)
      |> assign(:game, game)
      |> assign(:user, player_name) # TODO risky??

      BackupAgent.put(game_name, game)

      view = Game.client_view(game, player_name)

      send(self, :after_join) # self is a pid = socket.channel_pid

      {:ok, view, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    view = Game.client_view(socket.assigns[:game], socket.assigns[:user])
    broadcast socket, "update_view", view
    {:noreply, socket}
  end

  # def handle_in("sting", payload, socket) do
  #   name = socket.assigns[:name]
  #   game = GameServer.guess()
  #   player_name = "TODO"
  #   {:reply, {:waiting, %{"game" => Game.client_view(game, player_name)}}, socket}
  # end

  # def handle_in("place", payload, socket) do

  # end

  # defp update_state(socket, game) do
  #    name = socket.assigns[:name]
  #    socket = assign(socket, :game, game)
  #    BackupAgent.put(name, game)
  #    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  #  end

  defp authorized?(game_name, player_name) do
    # game is not full OR player is already in that game and re-connecting
    # Game.waiting_for_players?(game) || Game.has_player?(game, player_name)
    true
  end
end
