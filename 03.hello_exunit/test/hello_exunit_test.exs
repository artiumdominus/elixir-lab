defmodule HelloExunitTest do
  use ExUnit.Case
  doctest HelloExunit

  test "the truth" do
    assert 2 + 2 == 4
  end

  test "greets the world" do
    assert HelloExunit.hello() == :world
  end
end
