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
    {:ok, game} = place_caterpillar(game, "marie", :destroyer, 0, 0, true)
    assert client_view(game, "marie") == %{
      my_board: %{
        caterpillars: %{
          carrier:    [nil, nil, nil, nil, nil],
          battleship: [nil, nil, nil, nil],
          destroyer:    ["0,0", "1,0", "2,0"],
          submarine:  [nil, nil, nil],
          patrol:  [nil, nil]
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
    {:ok, game} = place_caterpillar(game, "marie", :patrol, 2, 0, false)
    {:ok, game} = place_caterpillar(game, "marie", :submarine, 3, 0, false)
    assert !setup_done?(game)
    {:ok, game} = place_caterpillar(game, "marie", :destroyer, 4, 0, false)
    assert setup_done?(game)

    # all players must be done setting up
    game = add_player(game, "brendan")
    assert !setup_done?(game)

    game = %{
      board_size: %{height: 10, width: 10},
      boards: %{
        "me" => %{
          caterpillars: %{
            battleship: [{2, 0}, {2, 1}, {2, 2}, {2, 3}],
            carrier: [{0, 0}, {0, 1}, {0, 2}, {0, 3}, {0, 4}],
            destroyer: [{3, 0}, {3, 1}, {3, 2}],
            patrol: [{5, 0}, {5, 1}],
            submarine: [{4, 0}, {4, 1}, {4, 2}]
          },
          status: %{}
        },
        "you" => %{
          caterpillars: %{
            battleship: [{0, 2}, {1, 2}, {2, 2}, {3, 2}],
            carrier: [{0, 0}, {1, 0}, {2, 0}, {3, 0}, {4, 0}],
            destroyer: [{0, 3}, {1, 3}, {2, 3}],
            patrol: [{0, 6}, {1, 6}],
            submarine: [{0, 5}, {1, 5}, {2, 5}]
          },
          status: %{}
        }
      },
      players: ["you", "me"],
      rankings: [],
      turn: "you"
    }
    assert setup_done?(game)

  end

  test "place caterpillar" do
    assert place_caterpillar(add_player(new(), "brendan"), "brendan", :destroyer, 0, 0, true) == 
      {:ok, 
        %{
          players: ["brendan"], 
          rankings: [],
          turn: "brendan", 
          boards: %{ "brendan" => %{
            caterpillars: %{
              carrier:    [nil, nil, nil, nil, nil],
              battleship: [nil, nil, nil, nil],
              destroyer:    [{0,0}, {1,0}, {2,0}],
              submarine:  [nil, nil, nil],
              patrol:  [nil, nil]
            },
            status: %{}
          }},
            board_size: %{ :width => 10, :height => 10 }
        }
      }
    assert place_caterpillar(add_player(new(), "brendan"), "brendan", :destroyer, 8, 8, false) == 
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
          destroyer:    [nil, nil, nil],
          submarine:  [nil, nil, nil],
          patrol:  [nil, nil]
        },
        status: %{{3, 4} => "miss"}
      }},
      board_size: %{ :width => 10, :height => 10 }
    }

    assert sting(game, "brendan", {3, 4}) == {:ok, stung_game}
    assert sting(stung_game, "brendan", {3, 4}) == {:error, stung_game}

    {:ok, stung_game} = place_caterpillar(stung_game, "brendan", :destroyer, 1, 1, true)
    assert sting(stung_game, "brendan", {2, 1}) == {:ok, 
      %{
        players: ["brendan"], 
        rankings: [],
        turn: "brendan", 
        boards: %{ "brendan" => %{
          caterpillars: %{
            carrier:    [nil, nil, nil, nil, nil],
            battleship: [nil, nil, nil, nil],
            destroyer:    [{1,1}, {2,1}, {3,1}],
            submarine:  [nil, nil, nil],
            patrol:  [nil, nil]
          },
          status: %{{2,1} => "hit", {3, 4} => "miss"}
        }},
        board_size: %{ :width => 10, :height => 10 }
      }
    }
  end

  test "next player" do
    game = add_player(add_player(new(), "a"), "b")
    assert game.turn == "b"
    assert next_player(game).turn == "a"
    assert next_player(next_player(game)).turn == "b"
    assert next_player(next_player(next_player(game))).turn == "a"
  end

  # Game Status -----------------------------------------------------------------------------------

  test "get game phase" do
    assert get_game_phase(new()) == "joining"
    assert get_game_phase(add_player(add_player(new(), "b"), "a")) == "setup"

    game = %{
      board_size: %{height: 10, width: 10},
      boards: %{
        "me" => %{
          caterpillars: %{
            battleship: [{2, 0}, {2, 1}, {2, 2}, {2, 3}],
            carrier: [{0, 0}, {0, 1}, {0, 2}, {0, 3}, {0, 4}],
            destroyer: [{3, 0}, {3, 1}, {3, 2}],
            patrol: [{5, 0}, {5, 1}],
            submarine: [{4, 0}, {4, 1}, {4, 2}]
          },
          status: %{}
        },
        "you" => %{
          caterpillars: %{
            battleship: [{0, 2}, {1, 2}, {2, 2}, {3, 2}],
            carrier: [{0, 0}, {1, 0}, {2, 0}, {3, 0}, {4, 0}],
            destroyer: [{0, 3}, {1, 3}, {2, 3}],
            patrol: [{0, 6}, {1, 6}],
            submarine: [{0, 5}, {1, 5}, {2, 5}]
          },
          status: %{}
        }
      },
      players: ["you", "me"],
      rankings: [],
      turn: "you"
    }
    assert get_game_phase(game) == "playing"
  end
end