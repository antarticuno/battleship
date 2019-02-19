defmodule BattleshipWeb.GamesChannel do
  use BattleshipWeb, :channel

  alias Battleship.Game
  alias Battleship.BackupAgent
  alias Battleship.GameServer

  def join("games:" <> game_name, payload, socket) do
    player_name = Map.get(payload, "player_name")
    # game = BackupAgent.get(game_name) || Game.new()
  
    if authorized?(game_name, player_name) do
      socket = assign(socket, :game, game_name)
      # game = GameServer.join(game_name, player_name)
      GameServer.join(game_name, player_name)
      # IO.puts("GAME STATE" <> inspect game)
      # socket = socket
      # |> assign(:game_name, game_name)
      # |> assign(:game, game)
      # |> assign(:user, player_name) # TODO risky??

      # view = Game.client_view(game, player_name)

      # {:ok, view, socket}
      # {:ok, game, socket}
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # def handle_info(:after_join, socket) do
  #   view = Game.client_view(socket.assigns[:game], socket.assigns[:user])
  #   broadcast socket, "update_view", view
  #   {:noreply, socket}
  # end

  # this isn't getting called for some reason?
  def handle_in("update_view", payload, socket) do
    IO.puts "update"
    IO.inspect payload
    # push socket, "update_view", payload

    broadcast socket, "update_view", payload
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
