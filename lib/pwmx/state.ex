defmodule Pwmx.State do
  defstruct chip: "", output: -1, period: -1, dc: -1, inverted: false, exported: false, enabled: false
  alias Pwmx.State

  def set_exported(%State{} = s), do: %{s | exported: true}
  def set_unexported(%State{} = s), do: %{s | exported: false}
  def set_inverted(%State{} = s), do: %{s | inverted: true}
  def set_not_inverted(%State{} = s), do: %{s | inverted: false}
  def set_period(%State{} = s, value), do: %{s | period: value}
  def set_duty_cycle(%State{} = s, value), do: %{s | dc: value}
  def set_chip(%State{} = s, value), do: %{s | chip: value}
  def set_output(%State{} = s, value), do: %{s | output: value}
  def set_enabled(%State{} = s, value), do: %{s | enabled: value}
end
