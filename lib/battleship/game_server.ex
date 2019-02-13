defmodule Battleship.GameServer do
  use GenServer

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
    Battleship.GameSup.start_child(spec)
  end

  def start_link(name) do
    game = Battleship.BackupAgent.get(name) || Battleship.Game.new()
    GenServer.start_link(__MODULE__, game, name: reg(name))
  end

  def guess(name, coordinate) do
    GenServer.call(reg(name), {:guess, name, letter})
  end

  def peek(name) do
    GenServer.call(reg(name), {:peek, name})
  end

  # Server Logic

  def init(game) do
    {:ok, game}
  end

  # TODO
  def handle_call({:sting, player, target, coordinate}, _from, game) do
    game = Battleship.Game.guess(game, target, coordinate)
    Battleship.BackupAgent.put(name, game)
    {:reply, game, game}
  end

  # TODO
  def handle_call({:peek, _name}, _from, game) do
    {:reply, game, game}
  end
end
