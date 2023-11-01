defmodule Pwmx.Backend do
  @moduledoc """
  Backend module, dispatching the system calls to Elixir.File on Linux, and (in the future) behaving
  in a way allowing to run tests on Mac or Windows. For the moment, running code that uses Pwmx on a
  non-linux OS will raise. That said, Pwmx.Output keeps track of requests to change state in a Pwmx.State
  struct, and that will allow to replicate the real behavior and query state without an hardware PWM chip.
  """

  alias Pwmx.Backend.Sysfs
  alias Pwmx.Backend.Virtual

  use GenServer
  @me __MODULE__

  def init(_init_arg) do
    {:ok,
     %{
       real: real?(),
       vchips: %{}
     }}
  end

  if Mix.env() == :test do
    defp real?, do: false
  else
    defp real?, do: File.dir?("/sys/class")
  end

  def start_link(_) do
    GenServer.start_link(@me, nil, name: @me)
  end

  def get_period(chip, output), do: GenServer.call(@me, {:get_period, chip, output})
  def get_duty_cycle(chip, output), do: GenServer.call(@me, {:get_duty_cycle, chip, output})
  def already_exported?(chip, output), do: GenServer.call(@me, {:already_exported?, chip, output})
  def export(chip, output), do: GenServer.call(@me, {:export, chip, output})
  def unexport(chip, output), do: GenServer.call(@me, {:unexport, chip, output})
  def enumerate_outputs(chip), do: GenServer.call(@me, {:enumerate_outputs, chip})

  @spec list_chips() :: {:ok, list(binary())} | {:error, any()}
  def list_chips, do: GenServer.call(@me, :list_chips)

  def set_period(chip, output, value, unit),
    do: GenServer.call(@me, {:set_period, chip, output, value, unit})

  def set_duty_cycle_absolute(chip, output, value, unit),
    do: GenServer.call(@me, {:set_duty_cycle_absolute, chip, output, value, unit})

  def set_duty_cycle_normalized(chip, output, value),
    do: GenServer.call(@me, {:set_duty_cycle_normalized, chip, output, value})

  def is_enabled?(chip, output), do: GenServer.call(@me, {:is_enabled?, chip, output})
  def enable(chip, output), do: GenServer.call(@me, {:enable, chip, output})
  def disable(chip, output), do: GenServer.call(@me, {:disable, chip, output})

  def set_polarity(chip, output, direction),
    do: GenServer.call(@me, {:set_polarity, chip, output, direction})

  def handle_call(msg, from, %{real: true} = state), do: Sysfs.handle_call(msg, from, state)
  def handle_call(msg, from, %{real: false} = state), do: Virtual.handle_call(msg, from, state)
end
