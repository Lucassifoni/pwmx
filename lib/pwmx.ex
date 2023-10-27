defmodule Pwmx do
  @moduledoc """
  Pure Elixir library to interact with the sysfs interface to hardware PWM on Linux.
  """

  def open(chip, output), do: Pwmx.Output.start_link({chip, output})

  def list_available_outputs(), do: Pwmx.Enumerator.list_available_outputs()
end
