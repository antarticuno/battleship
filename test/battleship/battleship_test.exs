defmodule Battleship.BattleshipTest do
	use ExUnit.Case
  import Battleship.Game

  test "add player" do
  	assert add_player(new(), "nat tuck") == %{
      players: ["nat tuck"], 
			rankings: [],
			turn: 0, 
			score: %{ "nat tuck" => 0 },
			boards: %{ "nat tuck" => new_board() }
		}
  end

  test "update score" do
  	assert update_score(add_player(new(), "jj"), "jj", 3) == %{
  		players: ["jj"], 
			rankings: [],
			turn: 0, 
			score: %{ "jj" => 3 },
			boards: %{ "jj" => new_board() }
		}
  end
end