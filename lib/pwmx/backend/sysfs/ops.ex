defmodule Pwmx.Backend.Sysfs.Ops do
  alias Pwmx.Paths
  alias Pwmx.Utils

  @moduledoc """
  Module performing the reads/writes on the sysfs paths. Separated from Pwmx.Backend.Sysfs so
  you can use it directly if you wish, without going through the stateful ceremony.
  """

  def set_polarity(chip, output, direction) do
    File.write(Paths.polarity_path(chip, output), "#{direction}")
  end

  def set_duty_cycle_absolute(chip, output, value, unit) do
    File.write(Paths.duty_cycle_path(chip, output), "#{Utils.to_nanoseconds(value, unit)}")
  end

  def is_enabled?(chip, output) do
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

  def get_period(chip, output) do
    case File.read(Paths.period_path(chip, output)) do
      {:ok, v} -> {:ok, v |> Utils.ensure_int!()}
      _ -> :error
    end
  end

  def already_exported?(chip, output) do
    File.dir?(Paths.output_path(chip, output))
  end

  def enable(chip, output) do
    File.write(Paths.enable_path(chip, output), "1")
  end

  def disable(chip, output) do
    File.write(Paths.enable_path(chip, output), "0")
  end

  def set_period(chip, output, value, unit) do
    File.write(Paths.period_path(chip, output), "#{Utils.to_nanoseconds(value, unit)}")
  end

  def list_chips do
    File.ls(Paths.base_path())
  end

  def enumerate_outputs(chip) do
    File.read(Paths.npwm_path(chip))
  end

  def export(chip, output) do
    File.write(Paths.export_path(chip), "#{output}")
  end

  def unexport(chip, output) do
    File.write(Paths.unexport_path(chip), "#{output}")
  end

  def get_duty_cycle(chip, output) do
    File.read(Paths.duty_cycle_path(chip, output))
  end
end
