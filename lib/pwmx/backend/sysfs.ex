defmodule Pwmx.Backend.Sysfs do
  @moduledoc """
  Sysfs backend for Pwmx, used on the target.
  """
  alias Pwmx.Paths
  alias Pwmx.Utils

  defp set_polarity(chip, output, direction, state) do
    if is_enabled?(chip, output, state) do
      {:reply, {:error, :e_output_enabled}, state}
    else
      {:reply, File.write(Paths.polarity_path(chip, output), direction), state}
    end
  end

  defp set_duty_cycle_absolute(chip, output, value, unit) do
    File.write(Paths.duty_cycle_path(chip, output), "#{Utils.to_nanoseconds(value, unit)}")
  end

  defp is_enabled?(chip, output, _state) do
    case File.read(Paths.enable_path(chip, output)) do
      {:ok, v} ->
        case v |> Utils.ensure_int!() do
          0 -> false
          1 -> true
        end

      _ ->
        false
    end
  end

  defp get_period(chip, output, _state) do
    case File.read(Paths.period_path(chip, output)) do
      {:ok, v} -> {:ok, v |> Utils.ensure_int!()}
      _ -> :error
    end
  end

  defp already_exported?(chip, output, _state) do
    File.dir?(Paths.output_path(chip, output))
  end

  def handle_call({:enable, chip, output}, _, s) do
    case File.write(Paths.enable_path(chip, output), "1") do
      :ok -> {:reply, :ok, s}
      _ -> {:reply, :error, s}
    end
  end

  def handle_call({:disable, chip, output}, _, s) do
    case File.write(Paths.enable_path(chip, output), "0") do
      :ok -> {:reply, :ok, s}
      _ -> {:reply, :error, s}
    end
  end

  def handle_call({:set_period, chip, output, value, unit}, _, s) do
    case File.write(Paths.period_path(chip, output), "#{Utils.to_nanoseconds(value, unit)}") do
      :ok -> {:reply, :ok, s}
      {:error, e} -> {:reply, {:error, e}, s}
    end
  end

  def handle_call({:set_duty_cycle_absolute, chip, output, value, unit}, _, s) do
    {:reply, set_duty_cycle_absolute(chip, output, value, unit), s}
  end

  def handle_call({:set_duty_cycle_normalized, chip, output, value}, _, s) do
    case get_period(chip, output, s) do
      {:ok, v} -> {:reply, set_duty_cycle_absolute(chip, output, trunc(v * value), :ns), s}
      _ -> {:reply, :error, s}
    end
  end

  def handle_call(:list_chips, _, s) do
    case File.ls(Paths.base_path()) do
      {:ok, chips} -> {:reply, {:ok, chips}, s}
      {:error, e} -> {:reply, {:error, e}, s}
    end
  end

  def handle_call({:enumerate_outputs, chip}, _, s) do
    case File.read(Paths.npwm_path(chip)) do
      {:ok, num} -> {:reply, {:ok, num |> Utils.ensure_int!()}, s}
      {:error, e} -> {:reply, {:error, e}, s}
    end
  end

  def handle_call({:export, chip, output}, _, s) do
    if already_exported?(chip, output, s) do
      {:reply, {:error, :already_exported}, s}
    else
      {:reply, File.write(Paths.export_path(chip), "#{output}"), s}
    end
  end

  def handle_call({:unexport, chip, output}, _, s) do
    if already_exported?(chip, output, s) do
      {:reply, File.write(Paths.unexport_path(chip), "#{output}"), s}
    else
      {:reply, {:error, :not_exported}, s}
    end
  end

  def handle_call({:get_duty_cycle, chip, output}, _, s) do
    case File.read(Paths.duty_cycle_path(chip, output)) do
      {:ok, v} -> {:reply, {:ok, v |> Utils.ensure_int!()}, s}
      _ -> {:reply, :error, s}
    end
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
