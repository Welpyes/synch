# Technical Architecture

Synch is designed for maximum speed and minimal resource usage on Linux and Android (Termux).

## Unified System Interface (`sys.lua`)
To prevent "attempt to redefine" errors in LuaJIT FFI, Synch uses a central utility called `utils.sys`. This file contains all the common `ffi.cdef` declarations for system structures (like `DIR`, `passwd`, `utsname`) and functions (like `opendir`, `getuid`, `uname`).

**Always require `utils.sys` instead of declaring common C symbols yourself.**

## Caching System
Synch caches static system information to `~/.cache/synch-cache.json` (or `/tmp` on some systems).

### What is cached?
- Kernel Name (e.g., `Linux`)
- GPU model and vendor strings.
- CPU model and frequency info.
- Motherboard/Host manufacturer and model.
- Architecture (e.g., `aarch64`).
- Distro Name (e.g., `Android`).

### What is NOT cached?
- Kernel Version (changes on updates).
- Hostname.
- Uptime.
- Packages.
- Shell version.
- DE/WM (switches between sessions).

## Bundling and Compilation
The `scripts/build.lua` script aggregates all modules and utilities into a single `bundle.lua` file. This bundle is then compiled using `luastatic` into a standalone binary, linking against `libluajit-5.1.a`. This results in a portable, single-file executable.

## Android/Termux Detection
Synch detects Termux by checking for the `PREFIX` environment variable. It uses `__system_property_get` via FFI to retrieve Android system properties (like `ro.product.model`) for accurate device detection.
