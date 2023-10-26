defmodule Pwmx.Backend do
  use GenServer
  @me __MODULE__

  def init(_init_arg) do
    {:ok, %{is_linux: is_linux?()}}
  end

  defp is_linux?(), do: File.dir?("/sys/class")

  def start_link(_) do
    GenServer.start_link(@me, nil, name: @me)
  end

  def dir?(path), do: GenServer.call(@me, {:dir, path})
  def read(path), do: GenServer.call(@me, {:read, path})
  def ls(path), do: GenServer.call(@me, {:ls, path})
  def write(path, value), do: GenServer.call(@me, {:write, path, value})

  def handle_call({:dir, path}, _, %{is_linux: true} = s), do:  {:reply, do_dir?(path), s}
  def handle_call({:read, path}, _, %{is_linux: true} = s), do: {:reply, do_read(path), s}
  def handle_call({:ls, path}, _, %{is_linux: true} = s), do: {:reply, do_ls(path), s}
  def handle_call({:write, path, value}, _, %{is_linux: true} = s), do: {:reply, do_write(path, value), s}

  def handle_call({:dir, _path}, _, %{is_linux: false}), do: unimplemented!()
  def handle_call({:read, _path}, _, %{is_linux: false}), do: unimplemented!()
  def handle_call({:ls, _path}, _, %{is_linux: false}), do: unimplemented!()
  def handle_call({:write, _path, _value}, _, %{is_linux: false}), do: unimplemented!()

  def unimplemented!(), do: raise "Mock backend for non-linux OSes not implemented yet."

  defp do_dir?(path) do
    File.dir?(path)
  end

  defp do_read(path) do
    File.read(path)
  end

  defp do_ls(path) do
    File.ls(path)
  end

  defp do_write(path, data) do
    File.write(path, data)
  end
end
