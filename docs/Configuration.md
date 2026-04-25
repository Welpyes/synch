# Configuration

Synch is configured using a TOML file located at `~/.config/synch/config.toml`.

## Global Settings

The `[global]` section controls which modules are loaded and their display order.

```toml
[global]
modules = [
  "logo",
  "user:user",
  "os",
  "host",
  "kernel",
  "uptime",
  "packages",
  "cpu",
  "gpu"
]
```

## Module Aliasing

You can load the same module multiple times with different names by using a colon `:` suffix. This is useful for displaying different parts of the same data separately.

Example:
```toml
[global]
modules = ["user:name", "user:host"]

[user:name]
format = "{user}"
key = "User"

[user:host]
format = "{host}"
key = "Host"
```

## Full Example Config

```toml
[global]
modules = ["logo", "os", "kernel", "uptime", "cpu", "gpu", "packages"]

[logo]
color = "light blue"

[os]
icon = "󰣇"
key = "OS"
format = "{name} {arch}"

[cpu]
icon-color = "red"
format-color = "red"
```
