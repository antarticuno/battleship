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
      |> assign(:user, player_name)

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

  # TODO implement this in Server and have server change whose turn it is after stinging
  def handle_in("sting", %{"opponent" => opponent, "x" => x, "y" => y}, socket) do
    game = socket.assigns[:game]
    player_name = socket.assigns[:user]
    target = {x, y}

    # check if player exists in game & that it is player_name's turn
    if (Game.can_sting?(game, player_name)) do
      {result, g} = Game.sting(game, opponent, target)
      if (result == :ok) do
        BackupAgent.put(socket.assigns[:name], g)     
        #TODO for some reason broadcasting same client view to all players...
        broadcast socket, "update_view", Game.client_view(g, player_name)

        {:noreply, socket}
        # {:reply, {:ok, %{"game" => Game.client_view(g, player_name)}}, socket}
      else
        broadcast socket, "error", Game.client_view(game, socket.assigns[:user])
        {:error, %{reason: g}}
      end


      {:reply, {:waiting, %{"game" => Game.client_view(game, player_name)}}, socket}
    else
      broadcast socket, "error", Game.client_view(game, socket.assigns[:user])
      {:reply, :error, %{reason: "invalid sting"}} # TODO
    end
  end

  def handle_in("place", %{ "type" => type, "start_x" => start_x, "start_y" => start_y, "horizontal?" => horizontal}, socket) do
    game = socket.assigns[:game]
    player_name = socket.assigns[:user]

    # TODO don't need to check if game has player I think
    if (Game.has_player?(game, player_name)) do
       # TODO make sure the types match place_caterpillar
      {result, g} = Game.place_caterpillar(game, player_name, String.to_atom(type), start_x, start_y, horizontal)
      if (result == :ok) do
        BackupAgent.put(socket.assigns[:name], g)     
        broadcast socket, "update_view", Game.client_view(g, player_name)

        {:reply, {:ok, %{"game" => Game.client_view(g, player_name)}}, socket}
      else
        broadcast socket, "error", Game.client_view(game, socket.assigns[:user])
        {:reply, {:error, %{reason: g}}}
      end
       
     else
       {:reply, {:error, %{reason: "No player for place"}}}
     end
  end

  # defp update_state(socket, game) do
  #    name = socket.assigns[:name]
  #    socket = assign(socket, :game, game)
  #    BackupAgent.put(name, game)
  #    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  #  end

  defp authorized?(game_name, player_name) do
    # TODO game is not full OR player is already in that game and re-connecting
    # Game.waiting_for_players?(game) || Game.has_player?(game, player_name)
    true
  end
end
