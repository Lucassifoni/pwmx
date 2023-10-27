defmodule Pwmx.Paths do
  @base_path "/sys/class/pwm"
  def base_path(), do: @base_path
  def chip_path(chip), do: Path.join(@base_path, chip)
  def npwm_path(chip), do: Path.join(chip_path(chip), "npwm")
  def output_path(chip, output), do: Path.join(chip_path(chip), "pwm#{output}")
  def export_path(chip), do: Path.join(chip_path(chip), "export")
  def unexport_path(chip), do: Path.join(chip_path(chip), "unexport")
  def period_path(chip, output), do: Path.join(output_path(chip, output), "period")
  def duty_cycle_path(chip, output), do: Path.join(output_path(chip, output), "duty_cycle")
  def polarity_path(chip, output), do: Path.join(output_path(chip, output), "polarity")
  def enable_path(chip, output), do: Path.join(output_path(chip, output), "enable")
end
