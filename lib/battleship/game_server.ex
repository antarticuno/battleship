defmodule Battleship.GameServer do
  use GenServer

  alias Battleship.BackupAgent
  alias Battleship.Game
  alias Battleship.GameSup

  # Client Interface

  def reg(name) do
    {:via, Registry, {Battleship.GameReg, name}}
  end

  def start(name) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [name]},
      restart: :permanent,
      type: :worker,
    }
    GameSup.start_child(spec)
  end

  def start_link(game_name) do
    game = BackupAgent.get(game_name) || Game.new()
    GenServer.start_link(__MODULE__, game, name: reg(game_name))
  end

  # runs after server is started with start_link
  def init(state) do
    {:ok, state}
  end

  def end_game(game_name) do
    IO.puts("removing " <> game_name)
    Registry.unregister(Battleship.GameReg, game_name)
    BackupAgent.remove(game_name)
    IO.inspect BackupAgent.get(game_name)
    IO.puts(length(Registry.lookup(Battleship.GameReg, game_name)))
  end

  def join(game_name, player_name) do
    if (length(Registry.lookup(Battleship.GameReg, game_name)) == 0) do
      start_link(game_name)
    end
    GenServer.cast(reg(game_name), {:join, game_name, player_name})
  end

  def place_caterpillar(game_name, player_name, type, start_x, start_y, horizontal) do
    GenServer.call(reg(game_name), {:place, game_name, player_name, type, start_x, start_y, horizontal})
  end

  def sting(game_name, opponent, coordinate) do
    GenServer.call(reg(game_name), {:sting, game_name, opponent, coordinate})
  end

  def get_game(game_name) do
    BackupAgent.get(game_name) || Game.new()
  end

  # Server Logic

  def handle_cast({:join, game_name, player_name}, _state) do
    game = Game.add_player(get_game(game_name), player_name)
    BackupAgent.put(game_name, game)
    broadcast(game, game_name)
    {:noreply, game}
  end

  def handle_call({:place, game_name, player_name, type, start_x, start_y, horizontal}, _from, _state) do
    game = get_game(game_name)
    {result, g} = Game.place_caterpillar(game, player_name, type, start_x, start_y, horizontal)
    update_and_broadcast(game_name, {result, g})
  end

  def handle_call({:sting, game_name, opponent, target}, _from, _state) do
    game = get_game(game_name)
    update_and_broadcast(game_name, Game.sting(game, opponent, target))
  end

  defp update_and_broadcast(game_name, {result, game}) do
    if result == :error do
      # TODO have some sort of try again message
    end

    Battleship.BackupAgent.put(game_name, game)
    broadcast(game, game_name)
    {:reply, game, game}
  end

  defp broadcast(state, game_name) do
    BattleshipWeb.Endpoint.broadcast("games:" <> game_name, "update", state)
  end
end
