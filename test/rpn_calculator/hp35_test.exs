defmodule RPNCalculator.HP35Test do
  use ExUnit.Case

  alias RPNCalculator.RPNCalculator

  @moduledoc """
  These are literal examples from the original HP-35 manual from the early seventies.
  """

  # page 3

  test "sum of the first 5 odd numbers" do
    assert_sequence([
      {"1", 1},
      {"Enter", 1},
      {"3", 3},
      {"Add", 4},
      {"5", 5},
      {"Add", 9},
      {"7", 7},
      {"Add", 16},
      {"9", 9},
      {"Add", 25}
    ])
  end

  test "product of the first 5 even numbers" do
    assert_sequence([
      {"2", 2},
      {"Enter", 2},
      {"4", 4},
      {"Multiply", 8},
      {"6", 6},
      {"Multiply", 48},
      {"8", 8},
      {"Multiply", 384},
      {"1", 1},
      {"0", 10},
      {"Multiply", 3840}
    ])
  end

  # page 3 & 4

  test "((2 + 3) / 4 + 5) x 6" do
    assert_sequence([
      {"2", 2},
      {"Enter", 2},
      {"3", 3},
      {"Add", 5},
      {"4", 4},
      {"Divide", 1.25},
      {"5", 5},
      {"Add", 6.25},
      {"6", 6},
      {"Multiply", 37.5}
    ])
  end

  # page 4 & 5

  test "sum of products" do
    assert_sequence([
      {"12", 12},
      {"Enter", 12},
      {"1.58", 1.58},
      {"Multiply", 18.96},
      {"8", 8},
      {"Enter", 8},
      {"2.67", 2.67},
      {"Multiply", 21.36},
      {"Add", 40.32},
      {"16", 16},
      {"Enter", 16},
      {".54", 0.54},
      {"Multiply", 8.64},
      {"Add", 48.96}
    ])
  end

  # page 5

  test "product of sums" do
    assert_sequence([
      {"7", 7},
      {"Enter", 7},
      {"3", 3},
      {"Add", 10},
      {"5", 5},
      {"Enter", 5},
      {"11", 11},
      {"Add", 16},
      {"Multiply", 160},
      {"13", 13},
      {"Enter", 13},
      {"17", 17},
      {"Add", 30},
      {"Multiply", 4800}
    ])
  end

  # page 8

  test "square root of 49" do
    assert_sequence([
      {"4", 4},
      {"9", 49},
      {"Sqrt", 7}
    ])
  end

  test "reciprocal of 25" do
    assert_sequence([
      {"2", 2},
      {"5", 25},
      {"Reciprocal", 0.04}
    ])
  end

  test "hypotenuse of a right triangle" do
    assert_sequence([
      {"3", 3},
      {"Enter", 3},
      {"Multiply", 9},
      {"4", 4},
      {"Enter", 4},
      {"Multiply", 16},
      {"Add", 25},
      {"Sqrt", 5}
    ])
  end

  test "area of circle" do
    assert_sequence([
      {"3", 3},
      {"Enter", 3},
      {"Multiply", 9},
      {"Pi", :math.pi()},
      {"Multiply", 3 ** 2 * :math.pi()}
    ])
  end

  test "2 to the power 7" do
    assert_sequence([
      {"7", 7},
      {"Enter", 7},
      {"2", 2},
      {"Power", 128}
    ])
  end

  # page 16-17

  test "9-th root of 512" do
    assert_sequence([
      {"512", 512},
      {"Enter", 512},
      {"9", 9},
      {"Reciprocal", 1 / 9},
      {"XY", 512},
      {"Power", :math.pow(512, 1 / 9)}
    ])
  end

  # page 18

  test "relation barometric pressure and altitude" do
    assert_sequence([
      {"25000", 25000},
      {"Enter", 25000},
      {"30", 30},
      {"Enter", 30},
      {"9.4", 9.4},
      {"Divide", 30 / 9.4},
      {"Ln", :math.log(30 / 9.4)},
      {"Multiply", :math.log(30 / 9.4) * 25000}
    ])
  end

  test "sine 30.5" do
    assert_sequence([
      {"30.5", 30.5},
      {"Sin", :math.sin(30.5 / 180 * :math.pi())}
    ])
  end

  # page 19

  test "cosine 150" do
    assert_sequence([
      {"150", 150},
      {"Cos", :math.cos(150 / 180 * :math.pi())}
    ])
  end

  test "tangent -25.6" do
    assert_sequence([
      {"25.6", 25.6},
      {"Sign", -25.6},
      {"Tan", :math.tan(-25.6 / 180 * :math.pi())}
    ])
  end

  test "inverse sine .3" do
    assert_sequence([
      {".3", 0.3},
      {"ArcSin", :math.asin(0.3) / :math.pi() * 180}
    ])
  end

  test "inverse cosine -.7" do
    assert_sequence([
      {".7", 0.7},
      {"Sign", -0.7},
      {"ArcCos", :math.acos(-0.7) / :math.pi() * 180}
    ])
  end

  test "inverse tangent 10.2" do
    assert_sequence([
      {"10.2", 10.2},
      {"ArcTan", :math.atan(10.2) / :math.pi() * 180}
    ])
  end

  defp assert_sequence(steps) do
    Enum.map_reduce(
      steps,
      %RPNCalculator{},
      fn {key, result}, rpn_calculator ->
        sub_keys = String.split(key, "", trim: true)

        rpn_calculator =
          if Enum.all?(sub_keys, fn x -> x in ~w(0 1 2 3 4 5 6 7 8 9 . -) end) do
            sub_keys =
              Enum.map(sub_keys, fn
                "." -> "Dot"
                "-" -> "Sign"
                key -> key
              end)

            RPNCalculator.process_keys(rpn_calculator, sub_keys)
          else
            RPNCalculator.process_key(rpn_calculator, key)
          end

        assert RPNCalculator.top_of_stack(rpn_calculator) == result
        {key, rpn_calculator}
      end
    )
  end
end
