# Pwmx  
Pure Elixir library to interact with the sysfs interface to hardware PWM on Linux.  
**state : public draft, do not use yet**

## Usage  

### Fully manual  
If you wish to just write and read to the sysfs Pwm interface, you can find path helpers in the `Pwmx.Paths` module.  

```elixir
File.read(Pwmx.Paths.duty_cycle_path("pwmchip0", "1"))
```

### Helper functions  
If you want an Elixir interface instead of calling `File.write/2` or `File.read/1` yourself, the module `Pwmx.Backend.Sysfs.Ops` has a stateless interface that actually performs the reads and writes.
```elixir
Pwmx.Backend.Sysfs.Ops.get_duty_cycle("pwmchip0", "1")
```

### Managed
The `Pwmx.Output` module can be used to spin up a genserver representing your output, managing its state.  
```elixir
{:ok, pid} = Pwmx.Output.start_link({"pwmchip0", 1})  
Pwmx.Output.enable(pid) |> Pwmx.Output.set_period(1_000_000, :us)  
```

## Testing & non-linux hosts
In a test or non-linux environment, the `Pwmx.Backend.Sysfs` module is not used, and calls are instead dispatched to `Pwmx.Backend.Virtual`, which keeps track of your operations on PWM outputs with the `Pwmx.State` struct. This struct isn't meant to be used directly as it wouldn't be of particular help.

### Todo

[ ] More tests now that the draft is written
[ ] Sample project showing behavior on a host & on a board


