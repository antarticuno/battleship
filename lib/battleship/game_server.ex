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

  def join(game_name, player_name) do
    if (length(Registry.lookup(Battleship.GameReg, game_name)) == 0) do
      start_link(game_name)
    end
    GenServer.cast(reg(game_name), {:join, game_name, player_name})
  end

  def place_caterpillar(game_name, player_name, type, start_x, start_y, horizontal) do
    GenServer.call(reg(game_name), {:place, game_name, player_name, type, start_x, start_y, horizontal})
  end

  def get_game(game_name) do
    BackupAgent.get(game_name) || Game.new()
  end

  # # TODO make sure to have a handle_call sting
  # def sting(game_name, coordinate, user_name, coordinate) do
  #   GenServer.call(__MODULE__, {:sting, game_name, user_name, coordinate})
  # end


  # Server Logic

  def handle_cast({:join, game_name, player_name}, _state) do
    game = Game.add_player(get_game(game_name), player_name)
    BackupAgent.put(game_name, game)
    broadcast(Game.client_view(game, player_name), game_name)
    {:noreply, game}
  end

  def handle_call({:place, game_name, player_name, type, start_x, start_y, horizontal}, _from, state) do
    game = get_game(game_name)
    {result, g} = Game.place_caterpillar(game, player_name, type, start_x, start_y, horizontal)
    BackupAgent.put(game_name, g)     

    case result do
      :ok -> broadcast(Game.client_view(g, player_name), game_name)
      :error -> broadcast(Game.client_view(game, player_name), game_name) # TODO add helpful error msg
    end
      {:reply, game, game}
  end

  # def handle_call({:sting, game_name, opponent, target}, _from, state) do
  #   game = get_game(game_name, state)
  #   game = Game.sting(game, target, target)
  #   broadcast(Game.client_view(game), game_name)
  #   Battleship.BackupAgent.put(game_name, game)
  #   {:reply, game, game}
  # end

  # # TODO
  # def handle_call({:new, _name}, _from, game) do
  #   {:reply, game, game}
  # end

  defp broadcast(state, game_name) do
    BattleshipWeb.Endpoint.broadcast("games:" <> game_name, "update_view", state)
  end
end
