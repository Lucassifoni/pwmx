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

## What PWM outputs do I have ?

An helper function can help you. Note that this function **actually exports then closes each output** as it seems that after a bit of testing, it cannot be taken for granted that every output reported by `/sys/class/pwm/chip/npwm` is able to be opened. Note that already exported outputs by something else in your system will not show up in this list as the export will fail.

```elixir
Pwmx.list_available_outputs()
[
    {"virtualchip0", 0},
    {"virtualchip0", 1},
    {"virtualchip0", 2},
    {"virtualchip0", 3}
]
```

### Todo

[ ] More tests now that a first draft is written  
[ ] Sample project showing behavior on a host & on a board  


