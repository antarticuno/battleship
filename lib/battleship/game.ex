defmodule Battleship.Game do

  alias Battleship.Board

  def new do
    %{
      player_names: [],
      rankings: [], # player names in order of who lost later -> earlier
      turn: "",      # index of player whose turn it is
      # score: %{},   # { player_name: Nat }
      boards: %{}   # { player_name : Board }
    }
  end

  def client_view(game, player_name) do
    {me, opponents} = Map.split(game.boards, [player_name])
    %{
      my_board: me,                                    # Map from player_name to Board
      opponents: opponents
                  |> Enum.map(fn {pn, board} -> {pn, Board.client_board(board)} end)
                  |> Map.new,                          # Map from player_name to Board status
      my_turn: game.turn == player_name,               # boolean for whether turn matches player_name
      lost: Enum.member?(game.rankings, player_name)   # boolean for whether player_name has been ranked
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
    |> Map.put(:players, [player_name | game.players])
    # |> Map.put(:score, Map.put(game.score, player_name, 0))
    |> Map.put(:boards, Map.put(game.boards, player_name, Board.new_board()))
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
    && !intersect?(Map.get(board, :caterpillars), start_x, start_y, end_x, end_y)
  end

  def in_bounds?(board_width, board_height, x, y) do
    x >= 0 && x < board_width && y >= 0 && y <= board_height
  end

  # would the caterpillar defined by start and end intersect with any others on the board?
  def intersect?(caterpillars, start_x, start_y, end_x, end_y) do
    caterpillar_coordinates = tween_coordinates(start_x, start_y, end_x, end_y)
    occupied_coordinates = List.flatten(Map.values(caterpillars))
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

  def sting(game, opponent, x, y) do
    {x, _} = Integer.parse(x)
    sting(game, opponent, stringify_posn(x, y))
  end
  def sting(game, opponent, target) do
    board = game.boards
    |> Map.get(opponent)    #get the Board for opponent
    |> Board.update_board(target) #delegate to Board to update_board
    if Board.lost?(board) do 
      game = Map.put(game, :rankings, [opponent | Map.get(game, :rankings)])
    end

    game
    |> Map.put(:boards, Map.put(game.boards, opponent, board))
    |> next_player
  end
  
  defp stringify_posn(x, y), do: <<65+x>> <> y

  # ASSUMES: current player is the one doing the guessing
  def guess(game, target, coordinate) do
    game #TODO delete and use sting in games_channel instead
  end

  # ASSUMES: player exists in game
  #def update_score(game, player_name, score_delta) do
  #  new_score = Map.get(game.score, player_name) + score_delta
  #  Map.put(game, :score, Map.put(game.score, player_name, new_score))
  #end

  def next_player(game) do
    remaining_players = game.players -- game.rankings
    next_index = remaining_players
                 |> Enum.find_index(&(&1 == game.turn))
                 |> Kernel.+(1)
                 |> rem(length(remaining_players))
    Map.put(game, :turn, Enum.at(remaining_players, next_index))
  end

  # Game Status -----------------------------------------------------------------------------------

  # def game_over?(game) do
    # remaining_players(game) == 0
  # end

  # have all of this player's caterpillars been killed?
  def player_lost?(game, player_name) do
    Board.lost(get_player_board(game, player_name))
  end
end
