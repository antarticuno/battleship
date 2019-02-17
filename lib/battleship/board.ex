defmodule Battleship.Board do

  def new_board do
    %{
      caterpillars: %{
        # TODO better way to store these?
        carrier:    ["", "", "", "", ""],
        battleship: ["","","",""],
        cruiser:    ["", "", ""],
        submarine:  ["", "", ""],
        destroyer:  ["", ""]
        },
      status: %{} # map from coordinate ("A6") to status ("hit" or "miss")
    }
  end

  def client_board(board), do: board.status

  def update_board(board, target) do
    status = board.status
    if (Map.has_key?(status, target)) do
      board #TODO do we be nice? or just return the board
    else
      if hit?(board, target) do
        board
        |> Map.put(:status, Map.put(status, target, "hit"))
      else
        board
        |> Map.put(:status, Map.put(status, target, "miss"))
      end
    end
  end

  # Assumes sting hasn't been made already
  defp hit?(board, target) do
    status = board.status
    board.caterpillars
    |> Map.values
    |> Enum.reduce(false, &(Enum.member?(&1, target) or &2))
  end

  defp dead?(caterpillar, status) do
    caterpillar
    |> Enum.reduce(true, &(Map.get(status, &1) == "hit"))
  end

  def lost?(board) do
    board.caterpillars
    |> Map.values
    |> Enum.reduce(true, &(dead?(&1, board.status)))
  end


end
