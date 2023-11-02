defmodule Pwmx.Backend.Sysfs do
  @moduledoc """
  Sysfs backend for Pwmx, used on the target.
  """
  alias Pwmx.Backend.Sysfs.Ops
  alias Pwmx.Utils

  def handle_call({:enable, chip, output}, _, s) do
    case Ops.enable(chip, output) do
      :ok -> {:reply, :ok, s}
      _ -> {:reply, :error, s}
    end
  end

  def handle_call({:disable, chip, output}, _, s) do
    case Ops.disable(chip, output) do
      :ok -> {:reply, :ok, s}
      _ -> {:reply, :error, s}
    end
  end

  def handle_call({:set_period, chip, output, value, unit}, _, s) do
    case Ops.set_period(chip, output, value, unit) do
      :ok -> {:reply, :ok, s}
      {:error, e} -> {:reply, {:error, e}, s}
    end
  end

  def handle_call({:set_duty_cycle_absolute, chip, output, value, unit}, _, s) do
    {:reply, Ops.set_duty_cycle_absolute(chip, output, value, unit), s}
  end

  def handle_call({:set_duty_cycle_normalized, chip, output, value}, _, s) do
    case Ops.get_period(chip, output) do
      {:ok, v} -> {:reply, Ops.set_duty_cycle_absolute(chip, output, trunc(v * value), :ns), s}
      _ -> {:reply, :error, s}
    end
  end

  def handle_call(:list_chips, _, s) do
    case Ops.list_chips() do
      {:ok, chips} -> {:reply, {:ok, chips}, s}
      {:error, e} -> {:reply, {:error, e}, s}
    end
  end

  def handle_call({:enumerate_outputs, chip}, _, s) do
    case Ops.enumerate_outputs(chip) do
      {:ok, num} -> {:reply, {:ok, num |> Utils.ensure_int!()}, s}
      {:error, e} -> {:reply, {:error, e}, s}
    end
  end

  def handle_call({:export, chip, output}, _, s) do
    if Ops.already_exported?(chip, output) do
      {:reply, {:error, :already_exported}, s}
    else
      {:reply, Ops.export(chip, output), s}
    end
  end

  def handle_call({:unexport, chip, output}, _, s) do
    if Ops.already_exported?(chip, output) do
      {:reply, Ops.unexport(chip, output), s}
    else
      {:reply, {:error, :not_exported}, s}
    end
  end

  def handle_call({:get_duty_cycle, chip, output}, _, s) do
    case Ops.get_duty_cycle(chip, output) do
      {:ok, v} -> {:reply, {:ok, v |> Utils.ensure_int!()}, s}
      _ -> {:reply, :error, s}
    end
  end

  def handle_call({:set_polarity, chip, output, direction}, _, state)
      when direction in [:normal, :inverted] do
    if Ops.is_enabled?(chip, output) do
      {:reply, {:error, :e_output_enabled}, state}
    else
      {:reply, Ops.set_polarity(chip, output, direction), state}
    end
  end

  def handle_call({:is_enabled?, chip, output}, _, s),
    do: {:reply, Ops.is_enabled?(chip, output), s}

  def handle_call({:get_period, chip, output}, _, s),
    do: {:reply, Ops.get_period(chip, output), s}

  def handle_call({:already_exported?, chip, output}, _, s),
    do: {:reply, Ops.already_exported?(chip, output), s}
end
