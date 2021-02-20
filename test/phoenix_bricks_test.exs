defmodule PhoenixBricksTest do
  use ExUnit.Case
  doctest PhoenixBricks

  test "greets the world" do
    assert PhoenixBricks.hello() == :world
  end
end
