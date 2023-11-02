defmodule Pwmx.Output do
  @moduledoc """
  The main user-facing module.
  """
  use GenServer
  @me __MODULE__
  alias Pwmx.Backend
  alias Pwmx.State

  def init({chip, output}) do
    with {:ok, chips} <- Backend.list_chips(),
         true <- chip in chips,
         true <- output < Backend.enumerate_outputs(chip),
         :ok <- Backend.export(chip, output) do
      state =
        %State{}
        |> State.set_chip(chip)
        |> State.set_output(output)
        |> State.set_exported()

      {:ok, state}
    else
      _ -> {:stop, :normal}
    end
  end

  def start_link(arg) do
    GenServer.start_link(@me, arg)
  end

  def close(pid), do: GenServer.cast(pid, :close)
  def get_period(pid), do: GenServer.call(pid, :get_period)
  def set_period(pid, value, unit \\ :ns), do: GenServer.call(pid, {:set_period, value, unit})

  def set_duty_cycle_absolute(pid, value, unit \\ :ns),
    do: GenServer.call(pid, {:set_duty_cycle_absolute, value, unit})

  def set_duty_cycle_normalized(pid, value),
    do: GenServer.call(pid, {:set_duty_cycle_normalized, value})

  def get_duty_cycle(pid), do: GenServer.call(pid, :get_duty_cycle)
  def is_enabled?(pid), do: GenServer.call(pid, :is_enabled?)
  def enable(pid), do: GenServer.call(pid, :enable)
  def disable(pid), do: GenServer.call(pid, :disable)
  def set_polarity(pid, :normal), do: GenServer.call(pid, {:set_polarity, :normal})
  def set_polarity(pid, :inverted), do: GenServer.call(pid, {:set_polarity, :inverted})
  def enumerate_outputs(pid), do: GenServer.call(pid, :enumerate_outputs)
  def unexport(pid), do: GenServer.call(pid, :unexport)
  def get_state(pid), do: GenServer.call(pid, :get_state)

  def handle_cast(:close, %State{} = state) do
    Backend.unexport(state.chip, state.output)
    Process.send_after(self(), :stop, 16)
    {:noreply, state}
  end

  def handle_info(:stop, _) do
    {:stop, :normal, nil}
  end

  def handle_call(:get_state, _, state) do
    {:reply, state, state}
  end

  def handle_call(:get_period, _, %State{} = state) do
    {:ok, period} = Backend.get_period(state.chip, state.output)
    {:reply, period, state |> State.set_period(period)}
  end

  def handle_call(:get_duty_cycle, _, %State{} = state) do
    {:ok, duty_cycle} = Backend.get_duty_cycle(state.chip, state.output)
    {:reply, duty_cycle, state |> State.set_duty_cycle(duty_cycle)}
  end

  def handle_call({:set_period, value, unit}, _, %State{} = state) do
    Backend.set_period(state.chip, state.output, value, unit)
    {:ok, period} = Backend.get_period(state.chip, state.output)
    {:reply, self(), state |> State.set_period(period)}
  end

  def handle_call({:set_duty_cycle_absolute, value, unit}, _, %State{} = state) do
    Backend.set_duty_cycle_absolute(state.chip, state.output, value, unit)
    {:ok, duty_cycle} = Backend.get_duty_cycle(state.chip, state.output)
    {:reply, self(), state |> State.set_duty_cycle(duty_cycle)}
  end

  def handle_call({:set_duty_cycle_normalized, value}, _, %State{} = state) do
    Backend.set_duty_cycle_normalized(state.chip, state.output, value)
    {:ok, duty_cycle} = Backend.get_duty_cycle(state.chip, state.output)
    {:reply, self(), state |> State.set_duty_cycle(duty_cycle)}
  end

  def handle_call(:is_enabled?, _, %State{} = state) do
    res = Backend.is_enabled?(state.chip, state.output)
    {:reply, res, state |> State.set_enabled(res)}
  end

  def handle_call(:enable, _, %State{} = state) do
    Backend.enable(state.chip, state.output)
    {:reply, self(), state |> State.set_enabled(true)}
  end

  def handle_call(:disable, _, %State{} = state) do
    Backend.disable(state.chip, state.output)
    {:reply, self(), state |> State.set_enabled(false)}
  end

  def handle_call({:set_polarity, :normal}, _, %State{} = state) do
    Backend.set_polarity(state.chip, state.output, :normal)
    {:reply, self(), state |> State.set_inverted()}
  end

  def handle_call({:set_polarity, :inverted}, _, %State{} = state) do
    Backend.set_polarity(state.chip, state.output, :inverted)
    {:reply, self(), state |> State.set_not_inverted()}
  end

  def handle_call(:enumerate_outputs, _, %State{} = state) do
    outputs = Backend.enumerate_outputs(state.chip)
    {:reply, outputs, state}
  end

  def handle_call(:unexport, _, %State{} = state) do
    Backend.unexport(state.chip, state.output)
    {:reply, :ok, state |> State.set_unexported()}
  end
end
