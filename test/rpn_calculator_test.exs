defmodule RPNCalculatorTest do
  use ExUnit.Case
  doctest RPNCalculator

  test "greets the world" do
    assert RPNCalculator.hello() == :world
  end
end
