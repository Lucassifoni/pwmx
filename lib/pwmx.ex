defmodule Pwmx do
  @moduledoc """
  Pure Elixir library to interact with the sysfs interface to hardware PWM on Linux.
  """

  def list_chips(), do: Pwmx.Sys.list_chips()

  def enumerate_outputs(chip), do: Pwmx.Sys.enumerate_outputs(chip)

  def open(chip, output), do: Pwmx.Output.start_link({chip, output})
end
