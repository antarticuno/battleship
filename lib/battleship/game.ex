defmodule Battleship.Game do

  alias Battleship.Board

  @num_players 2 # in the interest of scope, limit to two players

  def new do
    %{
      players: [],
      rankings: [], # player names in order of who lost later -> earlier
      turn: "",      # index of player whose turn it is
      boards: %{},   # { player_name : Board }
      board_size: %{ width: 10, height: 10 }
    }
  end

  def client_view(game, player_name) do
    {me, opponents} = Map.split(game.boards, [player_name])
    %{
      my_board: Board.client_my_board(Map.get(me, player_name)), # Board
      opponents: opponents
                  |> Enum.map(fn {pn, board} -> {pn, Board.client_opponent_board(board)} end)
                  |> Map.new,  # Map from player_name to Board status
      my_turn: game.turn == player_name,               
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

  # Joining Game  ---------------------------------------------------------------------------------

  def add_player(game, player_name) do
    if (has_player?(game, player_name) || get_game_phase(game) != "joining") do
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

  # Set-Up Phase ----------------------------------------------------------------------------------

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

  def can_sting?(game, player_name) do
    has_player?(game, player_name) && game.turn == player_name
  end

  # ASSUMES: player whose turn it is is doing the stinging
  def sting(game, opponent, target) do
    board = Map.get(game.boards, opponent)
    if (Board.valid_sting?(board, target)) do
      board = Board.update_status(board, target)
      game = game
      |> lost_player(board, opponent)
      |> set_player_board(opponent, board)
      |> next_player
      |> winning_player
      # |> advance_phase

      {:ok, game}  
    else
      {:error, game}
    end
  end

  def lost_player(game, board, opponent) do
    if (Board.lost?(board)) do
      Map.put(game, :rankings, [opponent | Map.get(game, :rankings)])
    else
      game
    end
  end

  def winning_player(game) do
    if (game_over?(game)) do
      Map.put(game, :rankings, [game.turn | Map.get(game, :rankings)])
    else 
      game
    end
  end

  def next_player(game) do
    if (!game_over?(game)) do
      remaining_players = remaining_players(game)
      next_index = remaining_players
                   |> Enum.find_index(&(&1 == game.turn))
                   |> Kernel.+(1)
                   |> rem(length(remaining_players))
      Map.put(game, :turn, Enum.at(remaining_players, next_index))
    else
      game
    end
  end

  # Game Status -----------------------------------------------------------------------------------

  # one of: "joining", "setup", "playing", "gameover"
  def get_game_phase(game) do
    cond do
      game_over?(game) -> "gameover"
      setup_done?(game) -> "playing"
      enough_players?(game) -> "setup"
      true -> "joining"
    end
  end



  def remaining_players(game), do: game.players -- game.rankings

  # are players still placing pieces on their boards?
  def setup_done?(game) do
    enough_players?(game) && 
    Enum.all?(Map.values(game.boards),
              fn board -> Board.all_caterpillars_placed?(board) end)
  end

  def enough_players?(game), do: length(game.players) == @num_players

  def game_over?(game) do
    enough_players?(game) &&
    setup_done?(game) &&
    length(remaining_players(game)) <= 1
  end
end
