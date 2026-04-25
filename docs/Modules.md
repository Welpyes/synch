# Modules Overview

Synch uses a modular system where each piece of information is retrieved by a specific script in the `modules/` directory.

## Available Modules

| Module | Description |
| :--- | :--- |
| `logo` | Renders a FIGlet text logo (usually the distro name). |
| `user` | Displays current username and hostname.  |
| `os` | Displays Operating System name, version, and architecture. |
| `de` | Detects the Desktop Environment (e.g., Plasma, MiUI). |
| `wm` | Detects the Window Manager or Compositor (e.g., bspwm, labwc). |
| `host` | Displays the device model and manufacturer. |
| `kernel` | Displays the kernel name and version. |
| `uptime` | Shows how long the system has been running. |
| `shell` | Detects the current shell and its version. |
| `cpu` | Displays CPU model, core count, and frequency. |
| `gpu` | Detects GPU model and type via Vulkan. |
| `packages` | Counts installed packages from multiple managers. |

## Module Execution

Modules are executed in the order defined in the `[global]` section of your `config.toml`. You can repeat modules or use aliases (e.g., `user:user` and `user:hostname`) to apply different configurations to the same underlying module script.
