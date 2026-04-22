-- Get the directory where synch.lua lives
local script_path = debug.getinfo(1).source:match("@?(.*)")
local script_dir = script_path:match("(.*[/\\])") or "./"

-- Add project directories to package path relative to the script location
package.path = package.path .. ";" .. script_dir .. "?.lua"

local toml = require("utils.toml")

local function read_file(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return content
end

local config_path = script_dir .. "config.toml"
local config_content = read_file(config_path)
local config = {}

if config_content then
  config = toml.parse(config_content)
else
  config = {
    global = { modules = { "logo" } },
    logo = { color = "blue" }
  }
end

-- Pre-load and calculate max key width
local loaded_modules = {}
local max_key_width = 0
if config.global and config.global.modules then
  for _, entry in ipairs(config.global.modules) do
    local module_name = entry:match("^([^:]+)")
    local module_config = config[entry]
    
    -- Cache modules to avoid repeated pcall/require overhead
    if not loaded_modules[module_name] then
      loaded_modules[module_name] = require("modules." .. module_name)
    end
    
    if module_config and module_config.key then
      max_key_width = math.max(max_key_width, #module_config.key)
    end
  end
end

-- Execution
if config.global and config.global.modules then
  for _, entry in ipairs(config.global.modules) do
    local module_name = entry:match("^([^:]+)")
    local module = loaded_modules[module_name]
    if module then
      module.run(config[entry], max_key_width)
    end
  end
end
