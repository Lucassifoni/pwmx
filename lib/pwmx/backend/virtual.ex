defmodule Pwmx.Backend.Virtual do
  @moduledoc """
  Virtual backend for Pwmx, mainly used for tests & hosts.
  """

  alias Pwmx.State
  alias Pwmx.Utils

  defp set_polarity(chip, output, direction, state) do
    if is_enabled?(chip, output, state) do
      {:reply, {:error, :e_output_enabled}, state}
    else
      new_s =
        case direction do
          "inverted" -> state |> update_state({:set_inverted, chip, output}, [])
          _ -> state |> update_state({:set_not_inverted, chip, output}, [])
        end

      {:reply, :ok, new_s}
    end
  end

  defp get_or_create_vchip(%{vchips: v}, chip, output) do
    Map.get(v, chip, %{}) |> Map.get(output, %State{})
  end

  defp update_state(state, {call, chip, output}, args) do
    old_output = get_or_create_vchip(state, chip, output)
    new_output = apply(State, call, [old_output | args])

    new_chip =
      state.vchips
      |> Map.get(chip, %{})
      |> Map.put(output, new_output)

    vchips = Map.put(state.vchips, chip, new_chip)
    state |> Map.put(:vchips, vchips)
  end

  defp is_enabled?(chip, output, state) do
    state.vchips[chip][output].enabled
  end

  defp get_period(chip, output, s) do
    {:ok, s.vchips[chip][output].period}
  end

  defp already_exported?(chip, output, s) do
    s.vchips[chip][output][:exported]
  end

  def handle_call({:enumerate_outputs, _chip}, _, s),
    do: {:reply, {:ok, 4}, s}

  def handle_call(:list_chips, _, s), do: {:reply, {:ok, ["virtualchip0"]}, s}

  def handle_call({:export, chip, output}, _, s) do
    new_s = s |> update_state({:set_exported, chip, output}, [])
    {:reply, :ok, new_s}
  end

  def handle_call({:unexport, chip, output}, _, s) do
    new_s = s |> update_state({:set_unexported, chip, output}, [])
    {:reply, :ok, new_s}
  end

  def handle_call({:get_duty_cycle, chip, output}, _, s),
    do: {:reply, {:ok, s.vchips[chip][output].duty_cycle}, s}

  def handle_call({:enable, chip, output}, _, s) do
    new_s = s |> update_state({:set_enabled, chip, output}, [true])
    {:reply, :ok, new_s}
  end

  def handle_call({:disable, chip, output}, _, s) do
    new_s = s |> update_state({:set_enabled, chip, output}, [false])
    {:reply, :ok, new_s}
  end

  def handle_call({:set_period, chip, output, value, unit}, _, s) do
    new_s = s |> update_state({:set_period, chip, output}, [Utils.to_nanoseconds(value, unit)])
    {:reply, :ok, new_s}
  end

  def handle_call({:set_duty_cycle_absolute, chip, output, value, unit}, _, s) do
    new_s =
      s |> update_state({:set_duty_cycle, chip, output}, [Utils.to_nanoseconds(value, unit)])

    {:reply, :ok, new_s}
  end

  def handle_call({:set_duty_cycle_normalized, chip, output, value}, _, s) do
    {:ok, v} = get_period(chip, output, s)
    new_s = s |> update_state({:set_duty_cycle, chip, output}, [trunc(v * value)])
    {:reply, :ok, new_s}
  end

  def handle_call({:set_polarity, chip, output, direction}, _, s)
      when direction in [:normal, :inverted] do
    set_polarity(chip, output, "#{direction}", s)
  end

  def handle_call({:is_enabled?, chip, output}, _, s),
    do: {:reply, is_enabled?(chip, output, s), s}

  def handle_call({:get_period, chip, output}, _, s),
    do: {:reply, get_period(chip, output, s), s}

  def handle_call({:already_exported?, chip, output}, _, s),
    do: {:reply, already_exported?(chip, output, s), s}
end
