defmodule Battleship.BackupAgent do
  use Agent
  
  def start_link(_args) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def put(name, val) do
    Agent.update __MODULE__, fn state ->
      Map.put(state, name, val)
    end
  end

  def get(name) do
    Agent.get __MODULE__, fn state ->
      Map.get(state, name)
    end
  end

  def remove(name) do
    Agent.get_and_update(__MODULE__, &(Map.pop(&1, name)))
  end
end
