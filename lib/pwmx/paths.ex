defmodule Pwmx.Paths do
  @moduledoc """
  Path helpers for the Sysfs backend.
  """

  @spec base_path() :: binary()
  @doc """
  The base sysfs path for PWM devices

      iex> Pwmx.Paths.base_path()
      "/sys/class/pwm"
  """
  def base_path, do: "/sys/class/pwm"

  @spec chip_path(binary()) :: binary()
  @doc """
  Path for a specific PWM chip

      iex> Pwmx.Paths.chip_path("virtualchip0")
      "/sys/class/pwm/virtualchip0"
  """
  def chip_path(chip), do: Path.join(base_path(), chip)

  @spec npwm_path(binary()) :: binary()
  @doc """
  Path giving the number of PWM outputs in a specific chip

      iex> Pwmx.Paths.npwm_path("virtualchip0")
      "/sys/class/pwm/virtualchip0/npwm"
  """
  def npwm_path(chip), do: Path.join(chip_path(chip), "npwm")

  @spec output_path(binary(), binary() | integer()) :: binary()
  @doc """
  Path for a specific PWM output in a specific chip

      iex> Pwmx.Paths.output_path("virtualchip0", 1)
      "/sys/class/pwm/virtualchip0/pwm1"
  """
  def output_path(chip, output), do: Path.join(chip_path(chip), "pwm#{output}")

  @spec export_path(binary()) :: binary()
  @doc """
  Path to export an output

      iex> Pwmx.Paths.export_path("virtualchip0")
      "/sys/class/pwm/virtualchip0/export"
  """
  def export_path(chip), do: Path.join(chip_path(chip), "export")

  @spec unexport_path(binary()) :: binary()
  @doc """
  Path to unexport an output

      iex> Pwmx.Paths.unexport_path("virtualchip0")
      "/sys/class/pwm/virtualchip0/unexport"
  """
  def unexport_path(chip), do: Path.join(chip_path(chip), "unexport")

  @spec period_path(binary(), binary() | integer()) :: binary()
  @doc """
  Path to set/read the period of an output

      iex> Pwmx.Paths.period_path("virtualchip0", 1)
      "/sys/class/pwm/virtualchip0/pwm1/period"
  """
  def period_path(chip, output), do: Path.join(output_path(chip, "#{output}"), "period")

  @spec duty_cycle_path(binary(), binary() | integer()) :: binary()
  @doc """
  Path to set/read the duty cycle of an output

      iex> Pwmx.Paths.duty_cycle_path("virtualchip0", 1)
      "/sys/class/pwm/virtualchip0/pwm1/duty_cycle"
  """
  def duty_cycle_path(chip, output), do: Path.join(output_path(chip, "#{output}"), "duty_cycle")

  @spec polarity_path(binary(), binary() | integer()) :: binary()
  @doc """
  Path to set/read the polarity of an output

      iex> Pwmx.Paths.polarity_path("virtualchip0", 1)
      "/sys/class/pwm/virtualchip0/pwm1/polarity"
  """
  def polarity_path(chip, output), do: Path.join(output_path(chip, "#{output}"), "polarity")

  @spec enable_path(binary(), binary() | integer()) :: binary()
  @doc """
  Path to enable or disable an output

      iex> Pwmx.Paths.enable_path("virtualchip0", 1)
      "/sys/class/pwm/virtualchip0/pwm1/enable"
  """
  def enable_path(chip, output), do: Path.join(output_path(chip, "#{output}"), "enable")
end
