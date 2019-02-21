defmodule Battleship.Board do

  def new do
    %{
      caterpillars: %{
        carrier:    [nil, nil, nil, nil, nil],
        battleship: [nil, nil, nil, nil],
        destroyer:    [nil, nil, nil],
        submarine:  [nil, nil, nil],
        patrol:  [nil, nil]
        },
      status: %{} # map from coordinate {x, y} to status ("hit" or "miss" or "sunk")
    }
  end

  def client_my_board(board) do
    caterpillars = board.caterpillars
    |> Enum.map(fn {k, coords} -> {k, convert_caterpillar(coords)} end)
    |> Map.new()

    board
    |> Map.put(:caterpillars, caterpillars)
    |> Map.put(:status, convert_status(board.status))
  end

  def client_opponent_board(board) do 
    convert_status(board.status)
  end

  defp convert_status(status) do
    status
    |> Enum.map(fn {coord, stat} -> {convert_coordinate(coord), stat} end)
    |> Map.new()
  end

  defp convert_caterpillar(coords) do
    coords
    |> Enum.map(fn c -> (if c == nil, do: nil, else: convert_coordinate(c)) end)
    |> Enum.to_list()
  end

  defp convert_coordinate(coordinate) do
    {x, y} = coordinate
    Integer.to_string(x) <> "," <> Integer.to_string(y)
  end

  # Stinging ---------------------------------------------------------------------------------------

  # target = {x, y}
  def valid_sting?(board, target), do: !Map.has_key?(board.status, target)

  # ASSUMES: target hasn't been stung already
  def update_status(board, target) do
    if hit?(board, target) do
      Map.put(board, :status, Map.put(board.status, target, "hit"))
    else
      Map.put(board, :status, Map.put(board.status, target, "miss"))
    end
  end

  # ASSUMES: target hasn't been stung already
  defp hit?(board, target) do
    status = board.status
    board.caterpillars
    |> Map.values
    |> Enum.reduce(false, &(Enum.member?(&1, target) or &2))
  end

  # Placing ---------------------------------------------------------------------------------------

  def all_caterpillars_placed?(board) do
    occupied_coordinates = List.flatten(Map.values(board.caterpillars))
    Enum.all?(occupied_coordinates, fn c -> c != nil end)    
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
      :destroyer -> 3
      :submarine -> 3
      :patrol -> 2
    end
  end

  # Status ----------------------------------------------------------------------------------------

  def dead?(caterpillar, status) do
    caterpillar
    |> Enum.all?(&(Map.get(status, &1) != "miss" && Map.get(status, &1) != nil))
  end

  def lost?(board) do
    board.caterpillars
    |> Map.values
    |> Enum.all?(&(dead?(&1, board.status)))
  end
end
