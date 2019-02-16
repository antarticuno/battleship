defmodule Battleship.BattleshipTest do
  use ExUnit.Case
  import Battleship.Game

  # Joining Game  ---------------------------------------------------------------------------------

  test "add player" do
    assert add_player(new(), "nat tuck") == %{
      player_names: ["nat tuck"], 
      rankings: [],
      turn: 0, 
      score: %{ "nat tuck" => 0 },
      boards: %{ "nat tuck" => new_board() },
      board_width: 10,
      board_height: 10
    }
  end

  # Set-Up Phase ----------------------------------------------------------------------------------

  test "tween coordinates" do
    assert tween_coordinates(0, 0, 3, 0) == [{0, 0}, {1, 0}, {2, 0}, {3, 0}]
    assert tween_coordinates(0, 1, 0, 5) == [{0, 1}, {0, 2}, {0, 3}, {0, 4}, {0, 5}]
    assert tween_coordinates(1, 1, 3, 3) == [{1, 1}, {2, 2}, {3, 3}]
    assert tween_coordinates(1, 1, 1, 1) == [{1, 1}]
  end

  # Guessing Phase --------------------------------------------------------------------------------

  test "update score" do
    assert update_score(add_player(new(), "jj"), "jj", 3) == %{
      player_names: ["jj"], 
      rankings: [],
      turn: 0, 
      score: %{ "jj" => 3 },
      boards: %{ "jj" => new_board() },
      board_width: 10,
      board_height: 10
    }
  end

  # Game Status -----------------------------------------------------------------------------------

  test "remaining players" do
    assert remaining_players(add_player(new(), "liz")) == 1
    # TODO test case where some players actually lost
  end

  test "player lost?" do
    assert player_lost?(add_player(new(), "brendan"), "brendan") == false
    # TODO test case where player did lose
  end
end