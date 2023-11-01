# Pwmx

Pure Elixir interface to Sysfs-based hardware PWM on Linux.

First draft thrown quickly together to think about it. Pre-alpha, comments welcome but do not use it yet.
The goal is to have a virtual backend able to totally mock the covered portion of the linux Sysfs interface, enabling us to have code running against a tested implementation on hosts.

### Todo

[ ] Remove unneeded indirection
[ ] Fully test
[ ] Sample project showing behavior on a host & on a board


