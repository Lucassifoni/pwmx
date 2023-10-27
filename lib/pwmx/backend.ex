defmodule Pwmx.Backend do
  alias Pwmx.State

  @moduledoc """
  Backend module, dispatching the system calls to Elixir.File on Linux, and (in the future) behaving
  in a way allowing to run tests on Mac or Windows. For the moment, running code that uses Pwmx on a
  non-linux OS will raise. That said, Pwmx.Output keeps track of requests to change state in a Pwmx.State
  struct, and that will allow to replicate the real behavior and query state without an hardware PWM chip.
  """
  use GenServer
  @me __MODULE__
  @base_path "/sys/class/pwm"

  def init(_init_arg) do
    {:ok,
     %{
       real: real?(),
       vchips: %{}
     }}
  end

  if Mix.env() == :test do
    defp real?(), do: false
  else
    defp real?(), do: File.dir?("/sys/class")
  end

  def start_link(_) do
    GenServer.start_link(@me, nil, name: @me)
  end

  defp to_ns(value, unit) do
    case unit do
      :s -> trunc(value * 1_000_000_000)
      :ms -> trunc(value * 1_000_000)
      :us -> trunc(value * 1_000)
      :ns -> value
    end
  end

  defp chip_path(chip), do: Path.join(@base_path, chip)
  defp npwm_path(chip), do: Path.join(chip_path(chip), "npwm")
  defp output_path(chip, output), do: Path.join(chip_path(chip), "pwm#{output}")
  defp export_path(chip), do: Path.join(chip_path(chip), "export")
  defp unexport_path(chip), do: Path.join(chip_path(chip), "unexport")
  defp period_path(chip, output), do: Path.join(output_path(chip, output), "period")
  defp duty_cycle_path(chip, output), do: Path.join(output_path(chip, output), "duty_cycle")
  defp polarity_path(chip, output), do: Path.join(output_path(chip, output), "polarity")
  defp enable_path(chip, output), do: Path.join(output_path(chip, output), "enable")
  defp ensure_int(value) when is_binary(value), do: value |> String.trim() |> String.to_integer()
  defp ensure_int(value) when is_integer(value), do: value

  def get_period(chip, output), do: GenServer.call(@me, {:get_period, chip, output})
  def get_duty_cycle(chip, output), do: GenServer.call(@me, {:get_duty_cycle, chip, output})
  def already_exported?(chip, output), do: GenServer.call(@me, {:already_exported?, chip, output})
  def export(chip, output), do: GenServer.call(@me, {:export, chip, output})
  def unexport(chip, output), do: GenServer.call(@me, {:unexport, chip, output})
  def enumerate_outputs(chip), do: GenServer.call(@me, {:enumerate_outputs, chip})
  def list_chips(), do: GenServer.call(@me, :list_chips)

  def set_period(chip, output, value, unit),
    do: GenServer.call(@me, {:set_period, chip, output, value, unit})

  def set_duty_cycle_absolute(chip, output, value, unit),
    do: GenServer.call(@me, {:set_duty_cycle_absolute, chip, output, value, unit})

  def set_duty_cycle_normalized(chip, output, value),
    do: GenServer.call(@me, {:set_duty_cycle_normalized, chip, output, value})

  def is_enabled?(chip, output), do: GenServer.call(@me, {:is_enabled?, chip, output})
  def enable(chip, output), do: GenServer.call(@me, {:enable, chip, output})
  def disable(chip, output), do: GenServer.call(@me, {:disable, chip, output})

  def set_polarity(chip, output, direction),
    do: GenServer.call(@me, {:set_polarity, chip, output, direction})

  defp set_polarity_p(chip, output, direction, state) do
    if is_enabled?(chip, output) do
      {:reply, {:error, :e_output_enabled}, state}
    else
      if state.real do
        {:reply, File.write(polarity_path(chip, output), direction), state}
      else
        new_s =
          case direction do
            "inverted" -> state |> update_state({:set_inverted, chip, output}, [])
            _ -> state |> update_state({:set_not_inverted, chip, output}, [])
          end

        {:reply, :ok, new_s}
      end
    end
  end

  defp get_or_create_vchip(%{vchips: v}, chip, output) do
    Map.get(v, chip, %{}) |> Map.get(output, %State{})
  end

  defp update_state(state, {call, chip, output}, args) do
    old_output = get_or_create_vchip(state, chip, output)
    new_output = apply(State, call, [old_output | args])

    new_chip =
      state.vchips
      |> Map.get(chip, %{})
      |> Map.put(output, new_output)

    vchips = Map.put(state.vchips, chip, new_chip)
    state |> Map.put(:vchips, vchips)
  end

  def handle_call({:enable, chip, output}, _, %{real: false} = s) do
    new_s = s |> update_state({:set_enabled, chip, output}, [true])
    {:reply, :ok, new_s}
  end

  def handle_call({:enable, chip, output}, _, %{real: true} = s) do
    case File.write(enable_path(chip, output), "1") do
      :ok -> {:reply, :ok, s}
      _ -> {:reply, :error, s}
    end
  end

  def handle_call({:disable, chip, output}, _, %{real: false} = s) do
    new_s = s |> update_state({:set_enabled, chip, output}, [false])
    {:reply, :ok, new_s}
  end

  def handle_call({:disable, chip, output}, _, %{real: true} = s) do
    case File.write(enable_path(chip, output), "0") do
      :ok -> {:reply, :ok, s}
      _ -> {:reply, :error, s}
    end
  end

  def handle_call({:set_polarity, chip, output, direction}, _, s)
      when direction in [:normal, :inverted] do
    set_polarity_p(chip, output, "#{direction}", s)
  end

  def handle_call({:is_enabled?, chip, output}, _, %{real: true} = s) do
    case File.read(enable_path(chip, output)) do
      {:ok, v} ->
        case v |> ensure_int do
          0 -> {:reply, false, s}
          1 -> {:reply, true, s}
        end

      _ ->
        {:reply, false, s}
    end
  end

  def handle_call({:set_period, chip, output, value, unit}, _, %{real: false} = s) do
    new_s = s |> update_state({:set_period, chip, output}, [to_ns(value, unit)])
    {:reply, :ok, new_s}
  end

  def handle_call({:set_period, chip, output, value, unit}, _, %{real: true} = s) do
    case File.write(period_path(chip, output), "#{to_ns(value, unit)}") do
      :ok -> {:reply, :ok, s}
      {:error, e} -> {:reply, {:error, e}, s}
    end
  end

  def handle_call({:set_duty_cycle_absolute, chip, output, value, unit}, _, %{real: false} = s) do
    new_s = s |> update_state({:set_duty_cycle, chip, output}, [to_ns(value, unit)])
    {:reply, :ok, new_s}
  end

  def handle_call({:set_duty_cycle_absolute, chip, output, value, unit}, _, %{real: true} = s) do
    {:reply, _set_duty_cycle_absolute(chip, output, value, unit), s}
  end

  def handle_call({:set_duty_cycle_normalized, chip, output, value}, _, %{real: false} = s) do
    case _get_period(chip, output, s) do
      {:ok, v} ->
        new_s = s |> update_state({:set_duty_cycle, chip, output}, [trunc(v * value)])
        {:reply, :ok, new_s}

      _ ->
        {:reply, :error, s}
    end
  end

  def handle_call({:set_duty_cycle_normalized, chip, output, value}, _, %{real: true} = s) do
    case _get_period(chip, output, s) do
      {:ok, v} -> {:reply, _set_duty_cycle_absolute(chip, output, trunc(v * value), :ns), s}
      _ -> {:reply, :error, s}
    end
  end

  def handle_call(:list_chips, _, %{real: false} = s), do: {:reply, {:ok, ["virtualchip0"]}, s}

  def handle_call(:list_chips, _, %{real: true} = s) do
    case File.ls(@base_path) do
      {:ok, chips} -> {:reply, {:ok, chips}, s}
      {:error, e} -> {:reply, {:error, e}, s}
    end
  end

  def handle_call({:enumerate_outputs, _chip}, _, %{real: false} = s),
    do: {:reply, {:ok, 4}, s}

  def handle_call({:enumerate_outputs, chip}, _, %{real: true} = s) do
    case File.read(npwm_path(chip)) do
      {:ok, num} -> {:reply, {:ok, num |> ensure_int}, s}
      {:error, e} -> {:reply, {:error, e}, s}
    end
  end

  def handle_call({:export, chip, output}, _, %{real: false} = s) do
    new_s = s |> update_state({:set_exported, chip, output}, [])
    {:reply, :ok, new_s}
  end

  def handle_call({:export, chip, output}, _, %{real: true} = s) do
    if _already_exported?(chip, output, s) do
      {:reply, {:error, :already_exported}, s}
    else
      {:reply, File.write(export_path(chip), "#{output}"), s}
    end
  end

  def handle_call({:unexport, chip, output}, _, %{real: false} = s) do
    new_s = s |> update_state({:set_unexported, chip, output}, [])
    {:reply, :ok, new_s}
  end

  def handle_call({:unexport, chip, output}, _, %{real: true} = s) do
    if _already_exported?(chip, output, s) do
      {:reply, File.write(unexport_path(chip), "#{output}"), s}
    else
      {:reply, {:error, :not_exported}, s}
    end
  end

  def handle_call({:get_period, chip, output}, _, s),
    do: {:reply, _get_period(chip, output, s), s}

  def handle_call({:get_duty_cycle, chip, output}, _, %{real: false} = s),
    do: {:reply, {:ok, s.vchips[chip][output].duty_cycle}, s}

  def handle_call({:get_duty_cycle, chip, output}, _, %{real: true} = s) do
    case File.read(duty_cycle_path(chip, output)) do
      {:ok, v} -> {:reply, {:ok, v |> ensure_int}, s}
      _ -> {:reply, :error, s}
    end
  end

  def handle_call({:already_exported?, chip, output}, _, s),
    do: {:reply, _already_exported?(chip, output, s), s}

  def _get_period(chip, output, %{real: false} = s) do
    {:ok, s.vchips[chip][output].period}
  end

  def _get_period(chip, output, %{real: true}) do
    case File.read(period_path(chip, output)) do
      {:ok, v} -> {:ok, v |> ensure_int}
      _ -> :error
    end
  end

  def _already_exported?(chip, output, %{real: false} = s) do
    s.vchips[chip][output][:exported]
  end

  def _already_exported?(chip, output, %{real: true}) do
    File.dir?(output_path(chip, output))
  end

  defp _set_duty_cycle_absolute(chip, output, value, unit) do
    File.write(duty_cycle_path(chip, output), "#{to_ns(value, unit)}")
  end
end
