defmodule Pwmx.Enumerator do
  alias Pwmx.Backend
  alias Pwmx.Output

  @moduledoc """
  Convenience module to enumerate *available* PWM outputs. The sysfs interface can report a number of
  pwm pins, but it is not guaranteed that all of them will be able to be exported.
  """

  @doc """
  Lists available outputs by opening (and closing) each of them

      iex> Pwmx.Enumerator.list_available_outputs()
      [
        {"virtualchip0", 0},
        {"virtualchip0", 1},
        {"virtualchip0", 2},
        {"virtualchip0", 3},
      ]
  """
  def list_available_outputs do
    case Backend.list_chips() do
      {:ok, chips} ->
        Enum.reduce(chips, [], fn c, out ->
          out ++ list_available_outputs_for_chip(c)
        end)

      _ ->
        []
    end
  end

  defp opened_pin(chip, i) do
    case Output.start_link({chip, i}) do
      {:ok, pid} ->
        Output.close(pid)
        [{chip, i}]

      _ ->
        []
    end
  end

  defp list_available_outputs_for_chip(chip) do
    case Backend.enumerate_outputs(chip) do
      {:ok, n} ->
        Enum.reduce(Range.new(0, n - 1), [], fn i, out ->
          out ++ opened_pin(chip, i)
        end)

      _ ->
        []
    end
  end
end
