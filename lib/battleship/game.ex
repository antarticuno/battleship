defmodule Battleship.Game do
 
  alias Battleship.Board

  def new do
    %{
      players: [],  # player names
      rankings: [], # player names in order of who lost later -> earlier
      turn: 0,      # index of player whose turn it is
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
                 |> Map.new,                           # Map from player_name to Board status
      my_turn: current_turn?(game, player_name),       # boolean for whether turn matches player_name
      lost: Enum.member?(game.rankings, player_name)   # boolean for whether player_name has been ranked
    }
  end

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
    |> Map.put(:turn, rem(Map.get(game, :turn) + 1, remaining_players(game)))
  end

  defp remaining_players(game), do: length(game.players -- game.ranking)
  
  defp stringify_posn(x, y), do: <<65+x>> <> y

  def add_player(game, player_name) do
    game 
    |> Map.put(:players, [player_name | game.players])
    # |> Map.put(:score, Map.put(game.score, player_name, 0))
    |> Map.put(:boards, Map.put(game.boards, player_name, Board.new_board()))
  end

  # ASSUMES: player exists in game
  #def update_score(game, player_name, score_delta) do
  #  new_score = Map.get(game.score, player_name) + score_delta
  #  Map.put(game, :score, Map.put(game.score, player_name, new_score))
  #end

  def current_turn?(game, player_name), do: Enum.at(game.players, game.turn) == player_name

  # are players still placing pieces on their boards?
  def setup_done?(game) do
    true # TODO
  end

end
