defmodule BattleshipWeb.GamesChannel do
  use BattleshipWeb, :channel

  alias Battleship.Game
  alias Battleship.GameServer

  intercept ["update", "error"]

  def join("games:" <> game_name, payload, socket) do
    player_name = Map.get(payload, "player_name")

    if authorized?(game_name, player_name) do
      socket = assign(socket, :game, game_name)
      socket = assign(socket, :user, player_name)

      GameServer.join(game_name, player_name)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized", message: "This game is full!"}}
    end
  end

  # intercepts messages from the server and applies client view for the specific player
  def handle_out("update", game, socket) do
    player_name = socket.assigns[:user]
    view = Game.client_view(game, player_name)
    # push rather than broadcast to make sure we send right client_view to right place
    push socket, "update_view", view
    {:noreply, socket}
  end

  # only show error message to the player that caused it
  def handle_out("error", err, socket) do
    player_name = socket.assigns[:user]
    if (player_name == err.recipient) do
      push socket, "error", err.error
    end
    {:noreply, socket}
  end

  def handle_in("place", %{ "type" => type, "start_x" => start_x, "start_y" => start_y, "horizontal?" => horizontal}, socket) do
    game_name = socket.assigns[:game]
    game = GameServer.get_game(game_name)
    player_name = socket.assigns[:user]
    GameServer.place_caterpillar(game_name, player_name, String.to_atom(type), start_x, start_y, horizontal)
    {:noreply, socket}
  end

  def handle_in("sting", %{"opponent" => opponent, "x" => x, "y" => y}, socket) do
    game_name = socket.assigns[:game]
    player_name = socket.assigns[:user]
    target = {x, y}
    GameServer.sting(game_name, player_name, opponent, target)
    {:noreply, socket}
  end

  def handle_in("new", _payload, socket) do
    game_name = socket.assigns[:game]
    GameServer.end_game(game_name)
    {:noreply, socket}
  end

  defp authorized?(game_name, player_name) do
    game = GameServer.get_game(game_name)
    !Game.enough_players?(game) || Game.has_player?(game, player_name)
  end
end
