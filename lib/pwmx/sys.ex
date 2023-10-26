defmodule Pwmx.Sys do
  @base_path "/sys/class/pwm"
  alias Pwmx.Backend

  def list_chips() do
    case Backend.ls(@base_path) do
      {:ok, chips} -> {:ok, chips}
      {:error, e} -> {:error, e}
    end
  end

  defp ensure_int(value) when is_binary(value), do: value |> String.trim |> String.to_integer
  defp ensure_int(value) when is_integer(value), do: value

  defp chip_path(chip), do: Path.join(@base_path, chip)
  defp npwm_path(chip), do: Path.join(chip_path(chip), "npwm")
  defp output_path(chip, output), do: Path.join(chip_path(chip), "pwm#{output}")
  defp export_path(chip), do: Path.join(chip_path(chip), "export")
  defp unexport_path(chip), do: Path.join(chip_path(chip), "unexport")
  defp period_path(chip, output), do: Path.join(output_path(chip, output), "period")
  defp duty_cycle_path(chip, output), do: Path.join(output_path(chip, output), "duty_cycle")
  defp polarity_path(chip, output), do: Path.join(output_path(chip, output), "polarity")
  defp enable_path(chip, output), do: Path.join(output_path(chip, output), "enable")

  defp to_ns(value, unit) do
    case unit do
      :s -> trunc(value * 1_000_000_000)
      :ms -> trunc(value * 1_000_000)
      :us -> trunc(value * 1_000)
      :ns -> value
    end
  end

  def get_period(chip, output) do
    case Backend.read(period_path(chip, output)) do
      {:ok, v} -> {:ok, v |> ensure_int}
      _ -> :error
    end
  end

  def get_dc(chip, output) do
    case Backend.read(duty_cycle_path(chip, output)) do
      {:ok, v} -> {:ok, v |> ensure_int}
      _ -> :error
    end
  end

  def set_period(chip, output, value, unit \\ :ms) do
    case Backend.write(period_path(chip, output), "#{to_ns(value, unit)}") do
      :ok -> :ok
      {:error, e} -> {:error, e}
    end
  end

  def set_dc_absolute(chip, output, value, unit \\ :ms) do
    case Backend.write(duty_cycle_path(chip, output), "#{to_ns(value, unit)}") do
      :ok -> :ok
      {:error, e} -> {:error, e}
    end
  end

  def set_dc_normalized(chip, output, value) when is_float(value) and value >= 0 and value <= 1 do
    case get_period(chip, output) do
      {:ok, v} -> set_dc_absolute(chip, output, trunc(v * value), :ns)
      _ -> :error
    end
  end

  def get_dc(chip, output) do
    case Backend.read(duty_cycle_path(chip, output)) do
      {:ok, v} -> {:ok, v |> ensure_int}
      _ -> :error
    end
  end

  def is_enabled?(chip, output) do
    case Backend.read(enable_path(chip, output)) do
      {:ok, v} -> case v |> ensure_int do
        0 -> false
        1 -> true
      end
      _ -> false
    end
  end

  def enable(chip, output) do
    case Backend.write(enable_path(chip, output), "1") do
      :ok -> :ok
      _ -> :error
    end
  end

  def disable(chip, output) do
    case Backend.write(enable_path(chip, output), "0") do
      :ok -> :ok
      _ -> :error
    end
  end

  defp set_polarity_p(chip, output, direction) do
    if is_enabled?(chip, output) do
      {:error, :e_output_enabled}
    else
      Backend.write(polarity_path(chip, output), direction)
    end
  end
  def set_polarity(chip, output, :normal), do: set_polarity_p(chip, output, "normal")
  def set_polarity(chip, output, :inverted), do: set_polarity_p(chip, output, "inverted")

  def enumerate_outputs(chip) do
    case Backend.read(npwm_path(chip)) do
      {:ok, num} -> {:ok, num |> ensure_int }
      {:error, e} -> {:error, e}
    end
  end

  defp already_exported?(chip, output), do: Backend.dir?(output_path(chip, output))

  def export(chip, output) do
    if already_exported?(chip, output) do
      {:error, :already_exported}
    else
      Backend.write(export_path(chip), "#{output}")
    end
  end

  def unexport(chip, output) do
    if already_exported?(chip, output) do
      Backend.write(unexport_path(chip), "#{output}")
    else
      {:error, :not_exported}
    end
  end

  def output_status(chip, output) do
    if already_exported?(chip, output) do
      :exported
    else
      nil
    end
  end
end
