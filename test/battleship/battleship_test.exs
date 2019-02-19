defmodule Battleship.BattleshipTest do
  use ExUnit.Case
  import Battleship.Game
  alias Battleship.Board

  test "client view" do
    assert client_view(add_player(new(), "nat tuck"), "nat tuck") == %{
      my_board: Board.client_my_board(Board.new()),
      opponents: %{},
      my_turn: true,
      lost: false,
      board_size: %{ height: 10, width: 10 },
      rankings: [],
      phase: "joining"
    }

    assert client_view(add_player(add_player(new(), "nat tuck"), "brendan"), "nat tuck") == %{
      my_board: Board.client_my_board(Board.new()),
      opponents: %{"brendan" => %{}},
      my_turn: false,
      lost: false,
      board_size: %{ height: 10, width: 10 },
      rankings: [],
      phase: "setup"
    }

    game = add_player(new(), "marie")
    {:ok, game} = place_caterpillar(game, "marie", :cruiser, 0, 0, true)
    assert client_view(game, "marie") == %{
      my_board: %{
        caterpillars: %{
          carrier:    [nil, nil, nil, nil, nil],
          battleship: [nil, nil, nil, nil],
          cruiser:    ["0,0", "1,0", "2,0"],
          submarine:  [nil, nil, nil],
          destroyer:  [nil, nil]
          },
        status: %{}
      },
      opponents: %{},
      my_turn: true,
      lost: false,
      board_size: %{ height: 10, width: 10 },
      rankings: [],
      phase: "joining"
    }
  end

  # Joining Game  ---------------------------------------------------------------------------------

  test "add player" do
    assert add_player(new(), "nat tuck") == %{
      players: ["nat tuck"], 
      rankings: [],
      turn: "nat tuck", 
      boards: %{ "nat tuck" => Board.new() },
      board_size: %{ width: 10, height: 10 }
    }
  end

  # Set-Up Phase ----------------------------------------------------------------------------------

  test "setup done?" do
    # game with no players is not done setting up
    assert !setup_done?(new())

    game = add_player(new(), "marie")
    {:ok, game} = place_caterpillar(game, "marie", :carrier, 0, 0, false)
    {:ok, game} = place_caterpillar(game, "marie", :battleship, 1, 0, false)
    {:ok, game} = place_caterpillar(game, "marie", :cruiser, 2, 0, false)
    {:ok, game} = place_caterpillar(game, "marie", :submarine, 3, 0, false)
    assert !setup_done?(game)
    {:ok, game} = place_caterpillar(game, "marie", :destroyer, 4, 0, false)
    assert setup_done?(game)

    # all players must be done setting up
    game = add_player(game, "brendan")
    assert !setup_done?(game)
  end

  test "place caterpillar" do
    assert place_caterpillar(add_player(new(), "brendan"), "brendan", :cruiser, 0, 0, true) == 
      {:ok, 
        %{
          players: ["brendan"], 
          rankings: [],
          turn: "brendan", 
          boards: %{ "brendan" => %{
            caterpillars: %{
              carrier:    [nil, nil, nil, nil, nil],
              battleship: [nil, nil, nil, nil],
              cruiser:    [{0,0}, {1,0}, {2,0}],
              submarine:  [nil, nil, nil],
              destroyer:  [nil, nil]
            },
            status: %{}
          }},
            board_size: %{ :width => 10, :height => 10 }
        }
      }
    assert place_caterpillar(add_player(new(), "brendan"), "brendan", :cruiser, 8, 8, false) == 
      {:error, add_player(new(), "brendan")}
  end

  # Playing Phase ---------------------------------------------------------------------------------

  test "sting" do
    game = add_player(new(), "brendan")

    stung_game = %{
      players: ["brendan"], 
      rankings: [],
      turn: "brendan", 
      boards: %{ "brendan" => %{
        caterpillars: %{
          carrier:    [nil, nil, nil, nil, nil],
          battleship: [nil, nil, nil, nil],
          cruiser:    [nil, nil, nil],
          submarine:  [nil, nil, nil],
          destroyer:  [nil, nil]
        },
        status: %{{3, 4} => "miss"}
      }},
      board_size: %{ :width => 10, :height => 10 }
    }

    assert sting(game, "brendan", {3, 4}) == {:ok, stung_game}
    assert sting(stung_game, "brendan", {3, 4}) == {:error, stung_game}

    {:ok, stung_game} = place_caterpillar(stung_game, "brendan", :cruiser, 1, 1, true)
    assert sting(stung_game, "brendan", {2, 1}) == {:ok, 
      %{
        players: ["brendan"], 
        rankings: [],
        turn: "brendan", 
        boards: %{ "brendan" => %{
          caterpillars: %{
            carrier:    [nil, nil, nil, nil, nil],
            battleship: [nil, nil, nil, nil],
            cruiser:    [{1,1}, {2,1}, {3,1}],
            submarine:  [nil, nil, nil],
            destroyer:  [nil, nil]
          },
          status: %{{2,1} => "hit", {3, 4} => "miss"}
        }},
        board_size: %{ :width => 10, :height => 10 }
      }
    }

  end

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