defmodule Battleship.Board do

  def new do
    %{
      caterpillars: %{
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

  # ASSUMES: valid coordinates for the caterpillar type
  def place_caterpillar(board, type, start_x, start_y, horizontal?) do
    coordinates = get_caterpillar_coordinates(type, start_x, start_y, horizontal?)
    caterpillars = Map.put(board.caterpillars, type, coordinates)
    Map.put(board, :caterpillars, caterpillars)
  end

  # ASSUMES: zero-indexed coordinates for start_x and start_y
  def valid_placement?(board, board_width, board_height, type, start_x, start_y, horizontal?) do
    coordinates = get_caterpillar_coordinates(type, start_x, start_y, horizontal?)
    {end_x, end_y} = List.last(coordinates)
    
    in_bounds?(board_width, board_height, start_x, start_y) 
    && in_bounds?(board_width, board_height, end_x, end_y) 
    && !intersect?(board.caterpillars, start_x, start_y, end_x, end_y)
  end

  def in_bounds?(board_width, board_height, x, y) do
    x >= 0 && x < board_width && y >= 0 && y < board_height
  end

  # would the caterpillar defined by start and end intersect with any others on the board?
  def intersect?(caterpillars, start_x, start_y, end_x, end_y) do
    caterpillar_coordinates = tween_coordinates(start_x, start_y, end_x, end_y)
    occupied_coordinates = List.flatten(Map.values(caterpillars))
    Enum.any?(caterpillar_coordinates, &(Enum.member?(occupied_coordinates, &1)))
  end

  def get_caterpillar_coordinates(type, start_x, start_y, horizontal?) do
    length = caterpillar_length(type) - 1
    end_x = if horizontal?, do: start_x + length, else: start_x
    end_y = if horizontal?, do: start_y, else: start_y + length

    tween_coordinates(start_x, start_y, end_x, end_y)
  end

  # create the list of coordinates between start and end
  def tween_coordinates(start_x, start_y, end_x, end_y) do
    x_coordinates = Enum.to_list(start_x..end_x)
    y_coordinates = Enum.to_list(start_y..end_y)

    cond do 
      (start_y == end_y) -> Enum.map(x_coordinates, fn x -> {x, start_y} end)
      (start_x == end_x) -> Enum.map(y_coordinates, fn y -> {start_x, y} end)
      true -> Enum.zip(x_coordinates, y_coordinates) # ASSUME: perfect diagonal
    end
  end

  defp caterpillar_length(type) do
    case type do
      :carrier -> 5
      :battleship -> 4
      :cruiser -> 3
      :submarine -> 3
      :destroyer -> 2
    end
  end

  # ASSUMES: sting hasn't been made already
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
