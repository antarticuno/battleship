defmodule Battleship.Game do
 
  alias Battleship.Board


  def new do
    %{
      players: [],  # player names
      rankings: [], # player names in order of who lost later -> earlier
      turn: 0,      # index of player whose turn it is
      score: %{},   # { player_name: Nat }
      boards: %{}   # { player_name : Board }
    }
  end

  def new_board do
    %{
      caterpillers: %{
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
    {me, opponents} = Map.split(game.boards, [player_name])
    stat = Map.get(myBoard, :caterpillers)
    lost = Enum.reduce(Map.values(stat), true,  fn {v, acc} -> acc and dead?(stat, v) end)
    %{
      my_board: myBoard, # Map from player_name to Board
      opponents:  Enum.each(opponentBoards, fn {k, v} -> {k, Map.get(v, :status)} end),
      my_turn: current_turn?(game, player_name),
      lost: lost
    }
  end

  def sting(game, target, x, y) do
    {x, _} = Integer.parse(x)
    coordinate = stringify_posn(x, y)
    # hit?
    # dead?
    # if so, update_score
    Map.put(game, :turn, rem(Map.get(game, :turn) + 1, remaining_players(game)))
  end

  def updateBoard(game, target, cell) do
    
  end

  # TODO fix this so that it accounts for loser players
  def remaining_players(game) do
    Enum.count(Map.get(game, :players))
  end
  
  def stringify_posn(x, y), do: <<65+x>> <> y
  def dead?(status, caterpillar), do: Enum.reduce(caterpillar, true, &(Map.get(status, &1) == "hit" and &2))

  def add_player(game, player_name) do
    game 
    |> Map.put(:players, [player_name | game.players])
    |> Map.put(:score, Map.put(game.score, player_name, 0))
    |> Map.put(:boards, Map.put(game.boards, player_name, new_board()))
  end

  # ASSUMES: player exists in game
  def update_score(game, player_name, score_delta) do
    new_score = Map.get(game.score, player_name) + score_delta
    Map.put(game, :score, Map.put(game.score, player_name, new_score))
  end

  def current_turn?(game, player_name) do
    Enum.at(game.players, game.turn) == player_name
  end

  # are players still placing pieces on their boards?
  def setup_done?(game) do
    true # TODO
  end

  # ASSUMES: current player is the one doing the guessing
  def guess(game, target, coordinate) do
    game #TODO
  end
end
