defmodule Battleship.BoardTest do
  use ExUnit.Case
  import Battleship.Board

  defp test_caterpillars do
    %{
      carrier:    [nil, nil, nil, nil, nil],
      battleship: [nil, nil, nil, nil],
      destroyer:    [nil, nil, nil],
      submarine:  [nil, nil, nil],
      patrol:  [nil, nil]
    }
  end

  test "client opponent board" do
    assert client_opponent_board(place_caterpillar(new(), :carrier, 3, 3, false)) == %{}
    assert client_opponent_board(update_status(new(), {3,4})) == %{"3,4" => "miss"}
  end

  # Stinging ---------------------------------------------------------------------------------------

  defp compare_status(board, key, expected) do
    assert board.status[key] == expected
  end

  test "valid sting?" do
    assert valid_sting?(new(), {3, 4})
    assert !valid_sting?(update_status(new(), {3, 4}), {3, 4})
  end

  test "update status" do
    compare_status(update_status(new(), {3,4}), {3,4}, "miss")

    board = place_caterpillar(new(), :carrier, 3, 3, false)
    compare_status(update_status(board, {3, 4}), {3, 4}, "hit")
  end

  # Placing ---------------------------------------------------------------------------------------

  defp compare_caterpillars(board, key, expected) do
    assert board.caterpillars[key] == expected
  end

  test "all caterpillars placed?" do
    assert !all_caterpillars_placed?(new())
    assert !all_caterpillars_placed?(place_caterpillar(new(), :carrier, 3, 3, false))

    board = new()
    |> place_caterpillar(:carrier, 0, 0, true)
    |> place_caterpillar(:battleship, 0, 1, true)
    |> place_caterpillar(:destroyer, 0, 2, true)
    |> place_caterpillar(:submarine, 0, 3, true)
    |> place_caterpillar(:patrol, 0, 4, true)

    assert all_caterpillars_placed?(board)
  end

  test "calculate caterpillar coordinates" do
    assert get_caterpillar_coordinates(:destroyer, 0, 0, true) == [{0, 0}, {1, 0}, {2, 0}]
    assert get_caterpillar_coordinates(:destroyer, 0, 0, false) == [{0, 0}, {0, 1}, {0, 2}]
    assert get_caterpillar_coordinates(:destroyer, 9, 9, false) == [{9, 9}, {9, 10}, {9, 11}]
    assert get_caterpillar_coordinates(:carrier, 0, 0, true) == [{0, 0}, {1, 0}, {2, 0}, {3, 0}, {4, 0}]
    assert get_caterpillar_coordinates(:carrier, 0, 0, false) == [{0, 0}, {0, 1}, {0, 2}, {0, 3}, {0, 4}]
  end

  test "place caterpillars" do
    assert compare_caterpillars(place_caterpillar(new(), :destroyer, 0, 0, false), :destroyer, [{0,0}, {0, 1}, {0, 2}])
    assert compare_caterpillars(place_caterpillar(new(), :carrier, 0, 0, true), :carrier, [{0,0}, {1, 0}, {2, 0}, {3, 0}, {4,0}])

    # duplicate placement replaces previous value
    board = place_caterpillar(new(), :destroyer, 0, 0, false)
    assert compare_caterpillars(place_caterpillar(board, :destroyer, 2, 2, true), :destroyer, [{2, 2}, {3, 2}, {4, 2}])
  end

  test "valid placement?" do
    assert valid_placement?(new(), 10, 10, :destroyer, 0, 0, true)
    assert valid_placement?(new(), 10, 10, :destroyer, 7, 7, true)
    assert valid_placement?(new(), 10, 10, :destroyer, 7, 7, false)
    # duplicate placement allowed (replaces previous value)
    board = place_caterpillar(new(), :destroyer, 0, 0, false)
    assert valid_placement?(board, 10, 10, :destroyer, 2, 2, false)
    # invalid if starts off board
    assert !valid_placement?(new(), 10, 10, :destroyer, 0, -1, true)
    assert !valid_placement?(new(), 10, 10, :destroyer, 0, -1, false)
    # invalid if would extend off board
    assert !valid_placement?(new(), 10, 10, :destroyer, 9, 9, true)
    assert !valid_placement?(new(), 10, 10, :destroyer, 9, 9, false)
    # invalid if intersects
    # TODO
  end

  test "intersect?" do
    assert !intersect?(test_caterpillars(), 0, 0, 0, 2)
    assert intersect?(Map.put(test_caterpillars(), :destroyer, [{0, 0}, {0, 1}]), 0, 0, 1, 0)
    assert intersect?(Map.put(test_caterpillars(), :destroyer, [{0, 0}, {0, 1}]), 0, 1, 0, 0)
    assert intersect?(Map.put(test_caterpillars(), :destroyer, [{1, 1}, {2, 1}, {3,1}]), 2, 0, 2, 2)
  end

  test "tween coordinates" do
    assert tween_coordinates(0, 0, 3, 0) == [{0, 0}, {1, 0}, {2, 0}, {3, 0}]
    assert tween_coordinates(0, 1, 0, 5) == [{0, 1}, {0, 2}, {0, 3}, {0, 4}, {0, 5}]
    assert tween_coordinates(1, 1, 3, 3) == [{1, 1}, {2, 2}, {3, 3}]
    assert tween_coordinates(1, 1, 1, 1) == [{1, 1}]
  end

  test "in bounds" do
    assert in_bounds?(10, 10, 0, 0)
    assert in_bounds?(10, 10, 9, 9)
    assert !in_bounds?(8, 8, 9, 0)
    assert !in_bounds?(8, 8, 0, 9)
    assert !in_bounds?(8, 8, -1, 0)
    assert !in_bounds?(8, 8, 0, -1)
  end
end
