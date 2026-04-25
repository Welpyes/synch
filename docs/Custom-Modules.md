# Creating Custom Modules

Adding a new module to Synch is straightforward. You need to create a Lua script in the `modules/` directory and (optional) a utility script in `utils/`.

## 1. The Module Script
Create `synch/modules/my_module.lua`. It must return a table with a `run` function.

```lua
local MyModule = {}
local formatter = require("utils.formatter")

function MyModule.run(config, max_width)
  config = config or {}
  
  -- 1. Get your data
  local my_data = "Hello World"
  
  -- 2. Define defaults
  local icon = config.icon or "󰋙"
  local key = config.key or "MyData"
  local format = config.format or "{val}"
  
  -- 3. Apply formatting
  local value = format:gsub("{val}", my_data)

  -- 4. Print using the central formatter
  print(formatter.format(icon, key, value, config, max_width))
end

return MyModule
```

## 2. The Utility Script (Optional)
If your module requires complex detection logic, put it in `synch/utils/get-my-data.lua`.

```lua
local sys = require("utils.sys") -- Use unified system interface

local MyUtil = {}

function MyUtil.get_data()
  -- Use sys.getenv, sys.readlink, or ffi calls here
  return "Data"
end

return MyUtil
```

## 3. Registering the Module
Add your module name to the `modules` list in `config.toml`:

```toml
[global]
modules = ["logo", "os", "my_module"]

[my_module]
key = "Custom"
format = "Value: {val}"
```
