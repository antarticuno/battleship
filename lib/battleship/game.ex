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
    stat = Map.get(myBoard, :caterpillers)
    lost = Enum.reduce(Map.values(stat), true,  fn {v, acc} -> acc and dead?(stat, v) end)
    %{
      my_board: myBoard, # Map from player_name to Board
      opponents:  Enum.each(opponentBoards, fn {k, v} -> {k, Map.get(v, :status)} end),
      my_turn: current_turn?(game, player_name),
      lost: Enum.member?(game.rankings, player_name)
    }
  end

  def sting(game, opponent, x, y) do
    {x, _} = Integer.parse(x)
    sting(game, opponent, stringify_posn(x, y))
  end
  def sting(game, opponent, target) do
    board = game.boards
    |> Map.get(opponent)    #get the Board for opponent
    |> update_board(target) #delegate to Board to update_board
    if lost?(board) do 
      game = Map.put(game, :rankings, [opponent | Map.get(game, :rankings)])
    end

    updated_game = game
    |> Map.put(:boards, Map.put(game.boards, opponent, board))
    |> Map.put(:turn, rem(Map.get(game, :turn) + 1), remaining_players(game))
  end

  def remaining_players(game), do: length(game.players -- game.ranking)
  
  def stringify_posn(x, y), do: <<65+x>> <> y

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
