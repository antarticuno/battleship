defmodule Battleship.Game do
  def new do
    %{
      player_names: [],
      rankings: [], # player names in order of who lost later -> earlier
      turn: 0,      # index of player whose turn it is
      score: %{},   # { player_name: Nat }
      boards: %{}   # { player_name : Board }
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

  # getter methods to reduce coupling to shape of game state

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

  def client_view(game, player_name) do
    caterpillars = get_player_caterpillars(game, player_name)
    opponentBoards = get_opponent_boards(game, player_name)
    
    %{
      my_board: get_player_board(game, player_name),
      opponents:  Enum.each(opponentBoards, fn {k, v} -> {k, Map.get(v, :status)} end),
      my_turn: current_turn?(game, player_name),
      lost: Enum.each(caterpillars, fn {k, v} -> dead?(caterpillars, v) end)
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

  def remaining_players(game) do
    Enum.count(Map.get(game, :player_names), &(player_lost?(game, &1) == false))
  end
  
  def stringify_posn(x, y), do: <<65+x>> <> y
  
  def add_player(game, player_name) do
    game 
    |> Map.put(:player_names, [player_name | game.player_names])
    |> Map.put(:score, Map.put(game.score, player_name, 0))
    |> Map.put(:boards, Map.put(game.boards, player_name, new_board()))
  end

  # have all of this player's caterpillars been killed?
  def player_lost?(game, player_name) do
    caterpillars = get_player_caterpillars(game, player_name)
    status = get_player_status(game, player_name)
    dead?(status, caterpillars)
  end

  def dead?(status, caterpillars), do: Enum.all?(caterpillars, &(Map.get(status, &1) == "hit"))

  # ASSUMES: player exists in game
  def update_score(game, player_name, score_delta) do
    new_score = Map.get(game.score, player_name) + score_delta
    Map.put(game, :score, Map.put(game.score, player_name, new_score))
  end

  def current_turn?(game, player_name) do
    Enum.at(game.player_names, game.turn) == player_name
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
