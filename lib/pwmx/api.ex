defmodule Pwmx.Api do
  @moduledoc """
  Module providing an abstracted API to Pwmx.Output
  This module will disappear as it just passes calls through to Pwmx.Backend
  """
  alias Pwmx.Backend

  def list_chips, do: Backend.list_chips()

  def get_period(chip, output), do: Backend.get_period(chip, output)
  def get_duty_cycle(chip, output), do: Backend.get_duty_cycle(chip, output)
  def enumerate_outputs(chip), do: Backend.enumerate_outputs(chip)

  def already_exported?(chip, output), do: Backend.already_exported?(chip, output)
  def export(chip, output), do: Backend.export(chip, output)
  def unexport(chip, output), do: Backend.unexport(chip, output)

  def set_period(chip, output, value, unit \\ :ns),
    do: Backend.set_period(chip, output, value, unit)

  def set_duty_cycle_absolute(chip, output, value, unit \\ :ms),
    do: Backend.set_duty_cycle_absolute(chip, output, value, unit)

  def set_duty_cycle_normalized(chip, output, value)
      when is_float(value) and value > 0 and value < 1,
      do: Backend.set_duty_cycle_normalized(chip, output, value)

  def is_enabled?(chip, output), do: Backend.is_enabled?(chip, output)
  def enable(chip, output), do: Backend.enable(chip, output)
  def disable(chip, output), do: Backend.disable(chip, output)

  def set_polarity(chip, output, direction) when direction in [:normal, :inverted],
    do: Backend.set_polarity(chip, output, direction)

  def output_status(chip, output),
    do: if(already_exported?(chip, output), do: :exported, else: nil)
end
