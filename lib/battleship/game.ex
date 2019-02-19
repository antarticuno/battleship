defmodule Battleship.Game do

  alias Battleship.Board

  @num_players 2

  def new do
    %{
      players: [],
      rankings: [], # player names in order of who lost later -> earlier
      turn: "",      # index of player whose turn it is
      boards: %{},   # { player_name : Board }
      board_size: %{ width: 10, height: 10 }
    }
  end

  def client_view(game) do
    boards = game.boards
             |> Enum.map(fn {pn, board} -> {pn, Board.client_board(board)} end)
    %{
       my_board: game.boards[0] |> Map.new,
       opponents: game.boards |> Map.new,
       my_turn: true,
       lost: false,
       board_size: game.board_size,
       rankings: game.rankings,
       phase: get_game_phase(game),
     }
  end

  def client_view(game, player_name) do
    {me, opponents} = Map.split(game.boards, [player_name])
    %{
      my_board: me,                                    # Map from player_name to Board
      opponents: opponents
                  |> Enum.map(fn {pn, board} -> {pn, Board.client_board(board)} end)
                  |> Map.new,                          # Map from player_name to Board status
      my_turn: game.turn == player_name,               
      lost: Enum.member?(game.rankings, player_name),
      board_size: game.board_size,
      rankings: game.rankings,
      phase: get_game_phase(game)  # one of: "joining", "setup", "playing", "gameover"
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
    if (has_player?(game, player_name)) do
      game
    else
      game 
      |> Map.put(:players, [player_name | game.players])
      |> Map.put(:turn, player_name) # TODO only add first player to join?
      |> Map.put(:boards, Map.put(game.boards, player_name, Board.new()))
    end    
  end

  def has_player?(game, player_name) do
    Enum.member?(game.players, player_name)
  end

  def waiting_for_players?(game), do: length(game.players) < @num_players
  def enough_players?(game), do: length(game.players) == @num_players

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

  # Playing Phase ---------------------------------------------------------------------------------

  # ASSUMES: player whose turn it is is doing the stinging
  def sting(game, opponent, target) do
    board = Map.get(game.boards, opponent)

    if (Board.valid_sting?(board, target)) do
      board = Board.update_status(board, target)

      if (Board.lost?(board)) do 
        game = Map.put(game, :rankings, [opponent | Map.get(game, :rankings)])
      end

      game = game
      |> set_player_board(opponent, board)
      |> next_player

      if (game_over?(game)) do
        game = Map.put(game, :rankings, [game.turn | Map.get(game, :rankings)])
      end
      {:ok, game}  
    else
      {:error, game}
    end
  end

  def next_player(game) do
    remaining_players = remaining_players(game)
    next_index = remaining_players
                 |> Enum.find_index(&(&1 == game.turn))
                 |> Kernel.+(1)
                 |> rem(length(remaining_players))
    Map.put(game, :turn, Enum.at(remaining_players, next_index))
  end

  # Game Status -----------------------------------------------------------------------------------

  # one of: "joining", "setup", "playing", "gameover"
  def get_game_phase(game) do
    cond do
      waiting_for_players?(game) -> "joining"
      enough_players?(game) -> "setup"
      setup_done?(game) -> "playing"
      game_over?(game) -> "gameover"
    end
  end

  def remaining_players(game), do: game.players -- game.rankings

  def game_over?(game), do: length(remaining_players(game)) == 0

  def player_lost?(game, player_name), do: Board.lost?(get_player_board(game, player_name))
end
