defmodule Pwmx.Utils do
  def to_ns(value, unit) do
    case unit do
      :s -> trunc(value * 1_000_000_000)
      :ms -> trunc(value * 1_000_000)
      :us -> trunc(value * 1_000)
      :ns -> value
    end
  end

  def ensure_int(value) when is_binary(value), do: value |> String.trim() |> String.to_integer()
  def ensure_int(value) when is_integer(value), do: value

end
