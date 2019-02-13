defmodule Battleship.GameServer do
  use GenServer

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

  def start_link(name) do
    game = Battleship.BackupAgent.get(name) || Battleship.Game.new()
    GenServer.start_link(__MODULE__, game, name: reg(name))
  end

  def guess(name, coordinate) do
    GenServer.call(reg(name), {:guess, name, coordinate})
  end

  def peek(name) do
    GenServer.call(reg(name), {:peek, name})
  end

  # Server Logic

  def init(game) do
    {:ok, game}
  end

  # TODO:
  # use broadcast function from Endpoint API to send the updated state to all
  def handle_call({:sting, name, target, coordinate}, _from, game) do
    game = Game.guess(game, target, coordinate)
    Battleship.BackupAgent.put(name, game)
    {:reply, game, game}
  end

  # TODO
  def handle_call({:new, _name}, _from, game) do
    {:reply, game, game}
  end

  # TODO
  def handle_call({:place, name, target, coordinate}, from, game) do
  
  end
end
