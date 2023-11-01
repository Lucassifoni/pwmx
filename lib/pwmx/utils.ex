defmodule Pwmx.Utils do
  @moduledoc """
  Utilities for type and units conversions.
  """

  @doc """
  Linux's sysfs PWM interface expects to get period and duty cycle values
  expressed in nanoseconds.
  """
  @spec to_nanoseconds(integer(), :ms | :ns | :s | :us) :: integer()
  def to_nanoseconds(value, unit) do
    case unit do
      :s -> value * 1_000_000_000
      :ms -> value * 1_000_000
      :us -> value * 1_000
      :ns -> value
    end
  end

  @doc """
  Ensures you have an integer in case you were passing a binary.
  Can raise, since String.to_integer/1 can raise an ArgumentError
  """
  @spec ensure_int!(binary() | integer()) :: integer()
  def ensure_int!(value) when is_binary(value), do: value |> String.trim() |> String.to_integer()
  def ensure_int!(value) when is_integer(value), do: value
end
