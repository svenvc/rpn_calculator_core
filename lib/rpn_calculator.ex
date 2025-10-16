defmodule RPNCalculator do
  @moduledoc """
  Documentation for `RPNCalculator`.
  """

  @doc """
  Create a new RPNCalculator model, a struct.

  ## Examples

      iex> RPNCalculator.new()
      %RPNCalculator.RPNCalculator{rpn_stack: [0], input_digits: "", computed?: false}

  """
  def new do
    %RPNCalculator.RPNCalculator{}
  end
end
