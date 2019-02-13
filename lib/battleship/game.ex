defmodule Battleship.Game do
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
    opponentBoards = Map.split(game.boards, [player_name])
    myBoard = Map.get(game.boards, player_name)
    stat = Map.get(myBoard, :caterpillers)
    %{
      my_board: myBoard,
      opponents:  Enum.each(opponentBoards, fn {k, v} -> {k, Map.get(v, :status)} end),
      my_turn: current_turn?(game, player_name),
      lost: Enum.each(Map.get(myBoard, :caterpillers), fn {k, v} -> dead?(stat, v) end)
    }
  end

  def dead?(status, caterpillar) do
    Enum.each(caterpillar, fn {loci} -> Map.get(status, loci) == "hit" end)
  end

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
