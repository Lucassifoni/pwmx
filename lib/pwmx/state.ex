defmodule Pwmx.State do
  @moduledoc """
  Struct keeping track of a PWM Output state. When developing on a non-linux box, or a linux box without PWM outputs, this struct is used instead of the sysfs calls. When running on the real board, this struct caches the values provided by the sysfs interface.
  """
  defstruct chip: "",
            output: -1,
            period: -1,
            duty_cycle: -1,
            inverted: false,
            exported: false,
            enabled: false

  @type t() :: %__MODULE__{}

  alias Pwmx.State

  @spec set_exported(t()) :: t()
  @doc """
  Sets the `exported` field to true.
      iex> %{exported: true} = (%Pwmx.State{} |> Pwmx.State.set_exported())
  """
  def set_exported(%State{} = s), do: %{s | exported: true}

  @spec set_unexported(t()) :: t()
  @doc """
  Sets the `exported` field to false.
      iex> %{exported: false} = (%Pwmx.State{} |> Pwmx.State.set_unexported())
  """
  def set_unexported(%State{} = s), do: %{s | exported: false}

  @spec set_inverted(t()) :: t()
  @doc """
  Sets the `inverted` field to true.
      iex> %{inverted: true} = (%Pwmx.State{} |> Pwmx.State.set_inverted())
  """
  def set_inverted(%State{} = s), do: %{s | inverted: true}

  @spec set_not_inverted(t()) :: t()
  @doc """
  Sets the `inverted` field to false.
      iex> %{inverted: false} = (%Pwmx.State{} |> Pwmx.State.set_not_inverted())
  """
  def set_not_inverted(%State{} = s), do: %{s | inverted: false}

  @spec set_period(t(), integer()) :: t()
  @doc """
  Sets the `period` field to an integer value.
      iex> %{period: 1000} = (%Pwmx.State{} |> Pwmx.State.set_period(1000))
  """
  def set_period(%State{} = s, value) when is_integer(value), do: %{s | period: value}

  @spec set_duty_cycle(t(), integer()) :: t()
  @doc """
  Sets the `duty_cycle` field to an integer value.
      iex> %{duty_cycle: 1000} = (%Pwmx.State{} |> Pwmx.State.set_duty_cycle(1000))
  """
  def set_duty_cycle(%State{} = s, value), do: %{s | duty_cycle: value}

  @spec set_chip(t(), binary()) :: t()
  @doc """
  Sets the `chip` field to a binary value.
      iex> %{chip: "virtualchip0"} = (%Pwmx.State{} |> Pwmx.State.set_chip("virtualchip0"))
  """
  def set_chip(%State{} = s, value) when is_binary(value), do: %{s | chip: value}

  @spec set_output(t(), integer()) :: t()
  @doc """
  Sets the `output` field to an integer value.
      iex> %{output: 1} = (%Pwmx.State{} |> Pwmx.State.set_output(1))
  """
  def set_output(%State{} = s, value) when is_integer(value), do: %{s | output: value}

  @spec set_enabled(t(), boolean()) :: t()
  @doc """
  Sets the `enabled` field to a boolean value.
      iex> %{enabled: false} = (%Pwmx.State{} |> Pwmx.State.set_enabled(false))
  """
  def set_enabled(%State{} = s, value) when is_boolean(value), do: %{s | enabled: value}
end
