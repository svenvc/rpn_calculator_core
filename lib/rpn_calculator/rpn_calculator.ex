defmodule RPNCalculator.RPNCalculator do
  defstruct rpn_stack: [0], input_digits: "", computed?: false

  def process_key(%__MODULE__{} = rpn_calculator, key)
      when key in ~w(0 1 2 3 4 5 6 7 8 9) do
    if rpn_calculator.input_digits == "" and rpn_calculator.computed? do
      rpn_calculator
      |> update_rpn_stack(fn [top | tail] -> [0 | [top | tail]] end, clear_input: false)
    else
      rpn_calculator
    end
    |> update_input_digits(fn input_digits ->
      cond do
        input_digits == "0" -> key
        true -> input_digits <> key
      end
    end)
    |> update_x()
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Dot") do
    rpn_calculator
    |> update_input_digits(fn input_digits ->
      if String.contains?(input_digits, ".") do
        input_digits
      else
        if input_digits == "" do
          "0."
        else
          input_digits <> "."
        end
      end
    end)
    |> update_x()
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Sign") do
    rpn_calculator =
      rpn_calculator
      |> update_input_digits(fn input_digits ->
        cond do
          input_digits == "" -> ""
          String.first(input_digits) == "-" -> String.slice(input_digits, 1..-1//1)
          true -> "-" <> input_digits
        end
      end)

    if rpn_calculator.input_digits == "" do
      rpn_calculator
      |> update_rpn_stack(fn [x | tail] -> [-x | tail] end, clear_input: false)
      |> update_computed?(true)
    else
      rpn_calculator
      |> update_x()
    end
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Clear") do
    rpn_calculator
    |> update_rpn_stack(fn rpn_stack ->
      if rpn_calculator.input_digits == "" do
        [0]
      else
        rpn_stack
      end
    end)
    |> update_x()
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Backspace") do
    rpn_calculator
    |> update_input_digits(fn input_digits ->
      cond do
        String.length(input_digits) == 2 and String.first(input_digits) == "-" -> ""
        true -> String.slice(input_digits, 0..-2//1)
      end
    end)
    |> update_x()
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Enter") do
    rpn_calculator
    |> update_rpn_stack(fn [top | tail] -> [top | [top | tail]] end)
    |> update_computed?(false)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Add") do
    rpn_calculator
    |> update_rpn_stack(fn
      [x | [y | tail]] -> [x + y | tail]
      rpn_stack -> rpn_stack
    end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Subtract") do
    rpn_calculator
    |> update_rpn_stack(fn
      [x | [y | tail]] -> [y - x | tail]
      rpn_stack -> rpn_stack
    end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Multiply") do
    rpn_calculator
    |> update_rpn_stack(fn
      [x | [y | tail]] -> [x * y | tail]
      rpn_stack -> rpn_stack
    end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Divide") do
    rpn_calculator
    |> update_rpn_stack(fn
      [_ | [0 | _]] = rpn_stack -> rpn_stack
      [x | [y | tail]] -> [y / x | tail]
      rpn_stack -> rpn_stack
    end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Power") do
    rpn_calculator
    |> update_rpn_stack(fn
      [x | [y | tail]] -> [:math.pow(x, y) | tail]
      rpn_stack -> rpn_stack
    end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Pi") do
    rpn_calculator
    |> update_rpn_stack(fn rpn_stack -> [:math.pi() | rpn_stack] end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "E") do
    rpn_calculator
    |> update_rpn_stack(fn rpn_stack -> [:math.exp(1) | rpn_stack] end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Reciprocal") do
    rpn_calculator
    |> update_rpn_stack(fn
      [0 | _] = rpn_stack -> rpn_stack
      [x | tail] -> [1 / x | tail]
    end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Sqrt") do
    rpn_calculator
    |> update_rpn_stack(fn [x | tail] -> [:math.sqrt(x) | tail] end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Exp") do
    rpn_calculator
    |> update_rpn_stack(fn [x | tail] -> [:math.exp(x) | tail] end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Log") do
    rpn_calculator
    |> update_rpn_stack(fn
      [0 | _] = rpn_stack -> rpn_stack
      [x | tail] -> [:math.log10(x) | tail]
    end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Ln") do
    rpn_calculator
    |> update_rpn_stack(fn
      [0 | _] = rpn_stack -> rpn_stack
      [x | tail] -> [:math.log(x) | tail]
    end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Sin") do
    rpn_calculator
    |> update_rpn_stack(fn [x | tail] -> [:math.sin(x / 180 * :math.pi()) | tail] end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Cos") do
    rpn_calculator
    |> update_rpn_stack(fn [x | tail] -> [:math.cos(x / 180 * :math.pi()) | tail] end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Tan") do
    rpn_calculator
    |> update_rpn_stack(fn
      [0 | _] = rpn_stack -> rpn_stack
      [x | tail] -> [:math.tan(x / 180 * :math.pi()) | tail]
    end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "ArcSin") do
    rpn_calculator
    |> update_rpn_stack(fn [x | tail] -> [:math.asin(x) / :math.pi() * 180 | tail] end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "ArcCos") do
    rpn_calculator
    |> update_rpn_stack(fn [x | tail] -> [:math.acos(x) / :math.pi() * 180 | tail] end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "ArcTan") do
    rpn_calculator
    |> update_rpn_stack(fn [x | tail] -> [:math.atan(x) / :math.pi() * 180 | tail] end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "XY") do
    rpn_calculator
    |> update_rpn_stack(fn
      [x | [y | tail]] -> [y | [x | tail]]
      rpn_stack -> rpn_stack
    end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "RollDown") do
    rpn_calculator
    |> update_rpn_stack(fn rpn_stack ->
      {top, rest} = List.pop_at(rpn_stack, 0)
      rest ++ [top]
    end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "RollUp") do
    rpn_calculator
    |> update_rpn_stack(fn rpn_stack ->
      {bottom, rest} = List.pop_at(rpn_stack, -1)
      [bottom] ++ rest
    end)
  end

  def process_key(%__MODULE__{} = rpn_calculator, "Drop") do
    rpn_calculator
    |> update_rpn_stack(fn
      [top] -> [top]
      [_top | tail] -> tail
    end)
  end

  def process_keys(%__MODULE__{} = rpn_calculator, keys) when is_list(keys) do
    Enum.reduce(
      keys,
      rpn_calculator,
      fn key, rpn_calculator -> process_key(rpn_calculator, key) end
    )
  end

  def top_of_stack(%__MODULE__{} = rpn_calculator) do
    [top_of_stack | _tail] = rpn_calculator.rpn_stack
    top_of_stack
  end

  defp update_rpn_stack(%__MODULE__{} = rpn_calculator, fun, opts \\ [clear_input: true]) do
    if Keyword.get(opts, :clear_input) do
      Map.update!(rpn_calculator, :rpn_stack, fun)
      |> clear_input()
    else
      Map.update!(rpn_calculator, :rpn_stack, fun)
    end
  end

  defp update_input_digits(%__MODULE__{} = rpn_calculator, fun) do
    Map.update!(rpn_calculator, :input_digits, fun)
  end

  defp update_computed?(%__MODULE__{} = rpn_calculator, boolean) do
    Map.replace!(rpn_calculator, :computed?, boolean)
  end

  defp update_x(%__MODULE__{} = rpn_calculator) do
    new_x = parse_input(rpn_calculator.input_digits)

    rpn_calculator
    |> update_rpn_stack(fn [_top | tail] -> [new_x | tail] end, clear_input: false)
    |> update_computed?(false)
  end

  defp clear_input(%__MODULE__{} = rpn_calculator) do
    rpn_calculator
    |> update_input_digits(fn _ -> "" end)
    |> update_computed?(true)
  end

  defp parse_input(""), do: 0

  defp parse_input(input_digits) do
    if String.contains?(input_digits, ".") do
      if String.last(input_digits) == "." do
        String.to_integer(String.slice(input_digits, 0..-2//1))
      else
        String.to_float(input_digits)
      end
    else
      String.to_integer(input_digits)
    end
  end
end
