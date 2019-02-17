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

  def hit?(board, target) do
    status = board.status
    if (Map.has_key?(status, target)) do 
      Map.get(status, target) == "hit"
    else
      board.caterpillars
      |> Map.values
      |> Enum.reduce(false, &(Enum.member?(&1, target) or &2))
    end
  end

  def dead?(caterpillar, status) do
    caterpillar
    |> Enum.reduce(true, &(Map.get(status, &1) == "hit"))
  end

  def lost?(board) do
    board.caterpillars
    |> Map.values
    |> Enum.reduce(true, &(dead?(&1, board.status)))
  end


end
