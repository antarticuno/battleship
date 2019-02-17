defmodule Battleship.BattleshipTest do
  use ExUnit.Case
  import Battleship.Game
  alias Battleship.Board

  # Joining Game  ---------------------------------------------------------------------------------

  test "add player" do
    assert add_player(new(), "nat tuck") == %{
      players: ["nat tuck"], 
      rankings: [],
      turn: "nat tuck", 
      # score: %{ "nat tuck" => 0 },
      boards: %{ "nat tuck" => Board.new() },
      board_size: %{ width: 10, height: 10 }
    }
  end

  # Set-Up Phase ----------------------------------------------------------------------------------

  test "place caterpillar" do
    assert place_caterpillar(add_player(new(), "brendan"), "brendan", :cruiser, 0, 0, true) == 
      {:ok, 
        %{
          players: ["brendan"], 
          rankings: [],
          turn: "brendan", 
          boards: %{ "brendan" => %{
            caterpillars: %{
              carrier:    ["", "", "", "", ""],
              battleship: ["","","",""],
              cruiser:    [{0,0}, {1,0}, {2,0}],
              submarine:  ["", "", ""],
              destroyer:  ["", ""]
              },
            status: %{}
          }},
            board_size: %{ :width => 10, :height => 10 }
        }
      }
    assert place_caterpillar(add_player(new(), "brendan"), "brendan", :cruiser, 8, 8, false) == 
      {:error, add_player(new(), "brendan")}
  end

  # Guessing Phase --------------------------------------------------------------------------------

  # test "update score" do
  #   assert update_score(add_player(new(), "jj"), "jj", 3) == %{
  #     player_names: ["jj"], 
  #     rankings: [],
  #     turn: 0, 
  #     score: %{ "jj" => 3 },
  #     boards: %{ "jj" => new_board() },
  #     board_width: 10,
  #     board_height: 10
  #   }
  # end

  # Game Status -----------------------------------------------------------------------------------

  # test "remaining players" do
  #   assert remaining_players(add_player(new(), "liz")) == 1
  #   # TODO test case where some players actually lost
  # end

  # test "player lost?" do
  #   assert player_lost?(add_player(new(), "brendan"), "brendan") == false
  #   # TODO test case where player did lose
  # end
end