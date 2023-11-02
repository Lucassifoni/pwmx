defmodule Pwmx do
  @moduledoc """
  Pure Elixir library to interact with the sysfs interface to hardware PWM on Linux.
  ## Usage
  ### Fully manual
  If you wish to just write and read to the sysfs Pwm interface, you can find path helpers in the
  Pwmx.Paths module.

      iex> File.read(Pwmx.Paths.duty_cycle_path("pwmchip0", "1"))

  ### Helper functions
  If you want an Elixir interface instead of calling File.write/2 or File.read/1 yourself, the module
  Pwmx.Backend.Sysfs.Ops has a stateless interface that actually performs the reads and writes.

      iex> Pwmx.Backend.Sysfs.Ops.get_duty_cycle("pwmchip0", 1)

  ### Managed
  The Pwmx.Output module can be used to spin up a genserver representing your output, managing its state.

      iex> {:ok, pid} = Pwmx.Output.start_link({"virtualchip0", 1})
      iex> Pwmx.Output.enable(pid) |> Pwmx.Output.set_period(1_000, :ms)
      iex> 1_000_000_000 = Pwmx.Output.get_period(pid)

  ## Testing & non-linux hosts
  In a test or non-linux environment, the Pwmx.Backend.Sysfs module is not used, and calls are instead dispatched
  to Pwmx.Backend.Virtual, which keeps track of your operations on PWM outputs with the Pwmx.State struct.
  This struct isn't meant to be used directly as it wouldn't be of particular help.
  """

  @doc """
  Spins up a Pwmx.Output GenServer.

      iex> {:ok, _pid} = Pwmx.open("virtualchip0", 3)
  """
  @spec open(binary(), integer()) :: {:error, :normal} | {:ok, pid()}
  def open(chip, output), do: Pwmx.Output.start_link({chip, output})

  @doc """
  Lists the available outputs

      iex> Pwmx.list_available_outputs()
      [
        {"virtualchip0", 0},
        {"virtualchip0", 1},
        {"virtualchip0", 2},
        {"virtualchip0", 3}
      ]
  """
  @spec list_available_outputs() :: list({binary(), integer()})
  def list_available_outputs, do: Pwmx.Enumerator.list_available_outputs()
end
