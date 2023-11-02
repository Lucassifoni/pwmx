defmodule PwmxTest do
  use ExUnit.Case
  doctest Pwmx
  doctest Pwmx.State
  doctest Pwmx.Utils
  doctest Pwmx.Paths
  doctest Pwmx.Enumerator
  doctest Pwmx.Backend
  doctest Pwmx.Backend.Virtual
  doctest Pwmx.Backend.Sysfs
end
