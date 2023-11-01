defmodule Pwmx.State do
  @moduledoc """
  Struct keeping track of a PWM Output state. This has two use-cases :
  - When developing on a non-linux box, or a linux box without PWM outputs, this struct
  is used instead of the sysfs calls
  - When running on the real board, this struct caches the values provided by
  the sysfs interface
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

  @spec set_exported(Pwmx.State.t()) :: Pwmx.State.t()
  def set_exported(%State{} = s), do: %{s | exported: true}

  @spec set_unexported(Pwmx.State.t()) :: Pwmx.State.t()
  def set_unexported(%State{} = s), do: %{s | exported: false}

  @spec set_inverted(Pwmx.State.t()) :: Pwmx.State.t()
  def set_inverted(%State{} = s), do: %{s | inverted: true}

  @spec set_not_inverted(Pwmx.State.t()) :: Pwmx.State.t()
  def set_not_inverted(%State{} = s), do: %{s | inverted: false}

  @spec set_period(Pwmx.State.t(), integer()) :: Pwmx.State.t()
  def set_period(%State{} = s, value), do: %{s | period: value}

  @spec set_duty_cycle(Pwmx.State.t(), integer()) :: Pwmx.State.t()
  def set_duty_cycle(%State{} = s, value), do: %{s | duty_cycle: value}

  @spec set_chip(Pwmx.State.t(), binary()) :: Pwmx.State.t()
  def set_chip(%State{} = s, value), do: %{s | chip: value}

  @spec set_output(Pwmx.State.t(), integer()) :: Pwmx.State.t()
  def set_output(%State{} = s, value), do: %{s | output: value}

  @spec set_enabled(Pwmx.State.t(), boolean()) :: Pwmx.State.t()
  def set_enabled(%State{} = s, value), do: %{s | enabled: value}
end
