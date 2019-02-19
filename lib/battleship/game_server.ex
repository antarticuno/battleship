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
    # game = Battleship.BackupAgent.get(game_name) || Game.new()
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # runs after server is started with start_link
  def init(state) do
    {:ok, state}
  end

  def join(game_name, player_name) do
    # GenServer.cast(reg(game_name), {:join, game_name, player_name})
    GenServer.cast(__MODULE__, {:join, game_name, player_name})
  end

  def get_game(game_name) do
    GenServer.call(__MODULE__, {:get_game, game_name})
  end

  def place_caterpillar(game_name, player_name, type, start_x, start_y, horizontal) do
    GenServer.call(__MODULE__, {:place, game_name, player_name, type, start_x, start_y, horizontal})  
  end

  # def view(game_name, player_name) do
  #   GenServer.call(__MODULE__, {:view, game_name, player_name})
  # end

  defp get_game(game_name, state) do
    backup = BackupAgent.get(game_name) || Game.new()
    Map.get(state, reg(game_name), backup)
  end

  # # TODO make sure to have a handle_call sting
  # def sting(game_name, coordinate, user_name, coordinate) do
  #   GenServer.call(__MODULE__, {:sting, game_name, user_name, coordinate})
  # end

  # # TODO place
  # def place(game_name, coordinate, direction, user_name) do
  #   GenServer.call(__MODULE__, {:place, game_name})
  # end


  # Server Logic

  def handle_cast({:join, game_name, player_name}, state) do
    game = Game.add_player(get_game(game_name, state), player_name)
    BackupAgent.put(game_name, game)
    # IO.puts("CAST CALLED" <> inspect game)

    broadcast(Game.client_view(game, player_name), game_name)
    {:noreply, Map.put(state, reg(game_name), game)}
  end

  def handle_call({:place, game_name, player_name, type, start_x, start_y, horizontal}, _from, state) do
    game = get_game(game_name, state)
    {result, g} = Game.place_caterpillar(game, player_name, type, start_x, start_y, horizontal)
    BackupAgent.put(game_name, g)     

    case result do
      :ok -> broadcast(Game.client_view(g, player_name), game_name)
      :error -> broadcast(Game.client_view(g, player_name), game_name) # TODO add helpful error msg
    end
      {:reply, game, game} # TODO idk if this is right
  end

  def handle_call({:get_game, game_name}, _from, state) do
    game = get_game(game_name, state)
    {:reply, game, game}
  end

  # def handle_call({:view, game_name, player_name}, _from, state) do
  #   game = Map.get(state, game_name, Game.new)
  #   # {:reply, Game.client_view(game, player_name), Map.put(state, game_name, game)}
  #   Hangman.BackupAgent.put(game_name, game)
  #   {:reply, game, game}
  # end

  # def handle_cast({:join, game_name, user_name}, _from, state) do
  #   game = Game.add_player(get_game(game_name, state), user_name)
  #   broadcast(Game.client_view(game), game_name)
  #   {:noreply, Map.put(state, game_name, game)}
  # end

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

  # # TODO
  # def handle_call({:place, game_name, user_name, type, start_x, start_y, direction}, _from, game) do
  #   game = Game.place_caterpillar(game, user_name, type, start_x, start_y, direction)
  #   Battleship.BackupAgent.put(game_name, game)
  #   broadcast(Game.client_view(game), game_name)
  #   {:reply, game, game}
  # end

  defp broadcast(state, game_name) do
    IO.puts("broadcasting to games:" <> game_name)
    IO.puts(inspect state)
    BattleshipWeb.Endpoint.broadcast("games:" <> game_name, "update_view", state)
  end
end
