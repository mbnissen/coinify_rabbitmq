defmodule CoinifyRabbitmqTest do
  use ExUnit.Case
  doctest CoinifyRabbitmq

  test "greets the world" do
    assert CoinifyRabbitmq.hello() == :world
  end
end
