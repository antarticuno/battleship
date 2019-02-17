defmodule Battleship.Game do

  alias Battleship.Board

  def new do
    %{
      players: [],
      rankings: [], # player names in order of who lost later -> earlier
      turn: "",      # index of player whose turn it is
      # score: %{},   # { player_name: Nat }
      boards: %{},   # { player_name : Board }
      board_size: %{ width: 10, height: 10 }
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
      lost: Enum.member?(game.rankings, player_name),   # boolean for whether player_name has been ranked
      board_size: game.board_size
    }
  end

  # Getter Methods for State ----------------------------------------------------------------------

  defp get_player_board(game, player_name) do
    Map.get(game.boards, player_name)
  end

  defp set_player_board(game, player_name, new_board) do
    Map.put(game, :boards, Map.put(game.boards, player_name, new_board))
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
    |> Map.put(:turn, player_name) # TODO only add first player to join?
    # |> Map.put(:score, Map.put(game.score, player_name, 0))
    |> Map.put(:boards, Map.put(game.boards, player_name, Board.new()))
  end

  # Set-Up Phase ----------------------------------------------------------------------------------

  # are players still placing pieces on their boards?
  def setup_done?(game) do
    length(game.players) > 0 && Enum.all?(Map.values(game.boards), fn board -> Board.all_caterpillars_placed?(board) end)
  end

  def place_caterpillar(game, player_name, type, start_x, start_y, horizontal?) do
    board = get_player_board(game, player_name)

    if (Board.valid_placement?(board, game.board_size.width, game.board_size.height, type, start_x, start_y, horizontal?)) do
      board = Board.place_caterpillar(board, type, start_x, start_y, horizontal?)
      game = set_player_board(game, player_name, board)
      {:ok, game}
    else
      {:error, game}  
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
    |> set_player_board(opponent, board)
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
