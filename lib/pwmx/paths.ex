defmodule Pwmx.Paths do
  @moduledoc """
  Path helpers for the Sysfs backend.
  """

  @spec base_path() :: binary()
  def base_path, do: "/sys/class/pwm"

  @spec chip_path(binary()) :: binary()
  def chip_path(chip), do: Path.join(base_path(), chip)

  @spec npwm_path(binary()) :: binary()
  def npwm_path(chip), do: Path.join(chip_path(chip), "npwm")

  @spec output_path(binary(), binary() | integer()) :: binary()
  def output_path(chip, output), do: Path.join(chip_path(chip), "pwm#{output}")

  @spec export_path(binary()) :: binary()
  def export_path(chip), do: Path.join(chip_path(chip), "export")

  @spec unexport_path(binary()) :: binary()
  def unexport_path(chip), do: Path.join(chip_path(chip), "unexport")

  @spec period_path(binary(), binary() | integer()) :: binary()
  def period_path(chip, output), do: Path.join(output_path(chip, "#{output}"), "period")

  @spec duty_cycle_path(binary(), binary() | integer()) :: binary()
  def duty_cycle_path(chip, output), do: Path.join(output_path(chip, "#{output}"), "duty_cycle")

  @spec polarity_path(binary(), binary() | integer()) :: binary()
  def polarity_path(chip, output), do: Path.join(output_path(chip, "#{output}"), "polarity")

  @spec enable_path(binary(), binary() | integer()) :: binary()
  def enable_path(chip, output), do: Path.join(output_path(chip, "#{output}"), "enable")
end
