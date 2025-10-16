defmodule RPNCalculatorTest do
  use ExUnit.Case
  doctest RPNCalculator

  test "create a new RPNCalculator" do
    rpn_calculator = RPNCalculator.new()
    assert rpn_calculator.rpn_stack == [0]
    assert rpn_calculator.input_digits == ""
    assert rpn_calculator.computed? == false
  end
end
