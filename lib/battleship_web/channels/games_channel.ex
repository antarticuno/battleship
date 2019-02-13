defmodule BattleshipWeb.GamesChannel do
  use BattleshipWeb, :channel

  alias Battleship.Game
  alias Battleship.BackupAgent

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = BackupAgent.get(name) || Game.new()
      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
      BackupAgent.put(name, game)
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  defp update_state(socket, game) do
     name = socket.assigns[:name]
     socket = assign(socket, :game, game)
     BackupAgent.put(name, game)
     {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
   end

  # TODO we'll likely need some logic here
  defp authorized?(_payload) do
    true
  end
end