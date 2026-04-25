# Module Customization

Every module in Synch can be fully customized via `config.toml`. Most modules share a common set of formatting options.

## Common Options

These options apply to almost every module except `logo`:

- `key`: The text label displayed after the icon.
- `icon`: The Nerd Font icon.
- `key-color`: Color of the key text.
- `icon-color`: Color of the icon.
- `format-color`: Color of the value text.
- `format`: A string template using placeholders (e.g., `{all}`).

## Individual Module Settings

### `logo`
- `color`: The ANSI color name or Hex code for the logo.
- `format`: Template for the text to be rendered. Use `{distro}` for the OS name.
- `text`: Manually override the logo text entirely.

### `gpu`
- `format`:
    - `{name}`: Name of the GPU.
    - `{type}`: Type (INTEGRATED_GPU, DISCRETE_GPU, etc.).
    - `{gpu1}`, `{gpu2}`: Access specific GPUs in multi-GPU systems.
    - `{all}`: Prints all GPUs on separate lines.

### `packages`
- `format`:
    - `{all}`: Total count of all packages.
    - `{detailed}`: Breakdown by manager (e.g., `518 (pacman)`).

### `os`
- `format`: `{name}`, `{release}`, `{version}`, `{arch}`.

### `kernel`
- `format`: `{name}`, `{version}`.

### `user`
- `format`: `{user}`, `{host}`.

### `uptime`
- `format`: `{time}` (e.g., `2d 4h 12m`).

### `shell`
- `format`: `{name}`, `{version}`.

### `cpu`
- `format`: `{cpu}`.

---

## Color Reference
Synch supports standard ANSI color names:
`black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`
and their light variants:
`light black`, `light red`, `light green`, `light yellow`, `light blue`, `light magenta`, `light cyan`, `light white`

Hex colors are also supported: `#RRGGBB`.
