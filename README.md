# Synch

A high-performance fetch program written in Lua for LuaJIT, inspired by [Synfetch](https://github.com/SXSLVT/synfetch) and [Nitch](https://github.com/ssleert/nitch).

## Features

- **Very Quick:** Powered by LuaJIT and optimized for minimal overhead.
- **Modular:** Easily extendable with custom system information modules.
- **Native Detection:** Leverages LuaJIT FFI for low-level system access, avoiding slow subshell spawns.
- **Customizable:** Fully configurable via TOML.
- **FIGlet Logos:** Built-in FIGlet font renderer for stylized text logos.
- **Persistent Caching:** Caches static system attributes (CPU, GPU, Motherboard) for near-instant execution.
- **Termux Compatibility:** I personally use termux and used it in development of this so expect it to work out of the box in it.

## Prerequisites

- `luajit`
- `vulkan headers` (for gpu information)
- [luastatic](https://github.com/ers35/luastatic) (only required for building a standalone binary)

## Installation

### Running from Source

```bash
luajit synch.lua
```

### Building the Binary

you need to install [luastatic](https://github.com/ers35/luastatic) to compile the project. You can use `luarocks` to install it.

```
luarocks install luastatic
```

Use the provided Makefile to bundle and compile the script into a standalone executable:

```bash
make
./synch
```

## Configuration

Synch looks for configuration at `~/.config/synch/config.toml`. If not found, it falls back to the internal default configuration.

You can customize module order and appearance in the `config.toml`:

```toml
[global]
modules = [
 "logo",
 "user:user",
 "os",
 "de",
 "wm",
 "host",
 "kernel",
 "uptime",
 "shell",
 "cpu",
 "gpu",
 "packages"
]
```

## Why Lua?

Lua is a versatile language that is exceptionally easy to modify and/or extend. By using LuaJIT, it achieves execution speeds of compiled progamming languages in the likes of Go or C while maintaining the flexibility and rapid development of a scripting language.
