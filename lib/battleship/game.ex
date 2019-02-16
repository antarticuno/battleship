defmodule Battleship.Game do
  def new do
    %{
      player_names: [],
      rankings: [], # player names in order of who lost later -> earlier
      turn: 0,      # index of player whose turn it is
      score: %{},   # { player_name: Nat }
      boards: %{},   # { player_name : Board }
      board_width: 10,
      board_height: 10
    }
  end

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

  def client_view(game, player_name) do
    caterpillars = get_player_caterpillars(game, player_name)
    opponentBoards = get_opponent_boards(game, player_name)
    
    %{
      board_dimensions: %{ width: game.board_width, height: game.board_height },
      my_board: get_player_board(game, player_name),
      opponents:  Enum.each(opponentBoards, fn {k, v} -> {k, Map.get(v, :status)} end),
      my_turn: current_turn?(game, player_name),
      lost: Enum.each(caterpillars, fn {k, v} -> dead?(caterpillars, v) end)
    }
  end

  # Getter Methods for State ----------------------------------------------------------------------

  defp get_player_board(game, player_name) do
    Map.get(game.boards, player_name)
  end

  defp get_player_caterpillars(game, player_name) do
    board = get_player_board(game, player_name)
    Map.get(board, :caterpillars)
  end

  defp get_player_status(game, player_name) do
    board = get_player_board(game, player_name)
    Map.get(board, :status)
  end

  defp get_opponent_boards(game, player_name) do
    Map.split(game.boards, [player_name])
  end

  # Joining Game  ---------------------------------------------------------------------------------

  def add_player(game, player_name) do
    game 
    |> Map.put(:player_names, [player_name | game.player_names])
    |> Map.put(:score, Map.put(game.score, player_name, 0))
    |> Map.put(:boards, Map.put(game.boards, player_name, new_board()))
  end

  # Set-Up Phase ----------------------------------------------------------------------------------

  # are players still placing pieces on their boards?
  def setup_done?(game) do
    true # TODO
  end

  def place_caterpillar(game, player_name, type, start_x, start_y, horizontal?) do
    board = get_player_board(game, player_name)

    if (valid_placement?(board, game.board_width, game.board_height, type, start_x, start_y, horizontal?)) do
      # TODO actually place caterpillar on board

      {:ok, game}
    else
      {:error, game}  
    end
  end

  # ASSUMES: zero-indexed coordinates for start_x and start_y
  def valid_placement?(board, board_width, board_height, type, start_x, start_y, horizontal?) do
    length = caterpillar_length(type)
    end_x = if horizontal?, do: start_x + length, else: start_x
    end_y = if horizontal?, do: start_y, else: start_y + length
    
    in_bounds?(board_width, board_height, start_x, start_y) 
      && in_bounds?(board_width, board_height, end_x, end_y) 
      && !intersect?(board, start_x, start_y, end_x, end_y)
  end

  def in_bounds?(board_width, board_height, x, y) do
    x >= 0 && x < board_width && y >= 0 && y <= board_height
  end

  # would the caterpillar defined by start and end intersect with any others on the board?
  def intersect?(board, start_x, start_y, end_x, end_y) do
    caterpillar_coordinates = tween_coordinates(start_x, start_y, end_x, end_y)
    occupied_coordinates = List.flatten(Map.values(Map.get(board, :caterpillars)))
    Enum.any?(caterpillar_coordinates, &(Enum.member?(occupied_coordinates, &1)))
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

  # Guessing Phase --------------------------------------------------------------------------------

  def sting(game, target, x, y) do
    {x, _} = Integer.parse(x)
    coordinate = stringify_posn(x, y)
    # hit?
    # dead?
    # if so, update_score
    Map.put(game, :turn, rem(Map.get(game, :turn) + 1, remaining_players(game)))
  end

  # ASSUMES: current player is the one doing the guessing
  def guess(game, target, coordinate) do
    game #TODO delete and use sting in games_channel instead
  end

  def stringify_posn(x, y), do: <<65+x>> <> y

  # ASSUMES: player exists in game
  def update_score(game, player_name, score_delta) do
    new_score = Map.get(game.score, player_name) + score_delta
    Map.put(game, :score, Map.put(game.score, player_name, new_score))
  end

  # Game Status -----------------------------------------------------------------------------------

  def current_turn?(game, player_name) do
    Enum.at(game.player_names, game.turn) == player_name
  end

  def game_over?(game) do
    remaining_players(game) == 0
  end

  def remaining_players(game) do
    Enum.count(Map.get(game, :player_names), &(player_lost?(game, &1) == false))
  end

  # have all of this player's caterpillars been killed?
  def player_lost?(game, player_name) do
    caterpillars = get_player_caterpillars(game, player_name)
    status = get_player_status(game, player_name)
    dead?(status, caterpillars)
  end

  def dead?(status, caterpillars), do: Enum.all?(caterpillars, &(Map.get(status, &1) == "hit"))
end