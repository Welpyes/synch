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
  -- Default config if file missing
  config = {
    global = { modules = { "logo" } },
    logo = { color = "blue" }
  }
end

if config.global and config.global.modules then
  for _, module_name in ipairs(config.global.modules) do
    local success, module = pcall(require, "modules." .. module_name)
    if success then
      module.run(config[module_name])
    else
      print("Error loading module: " .. module_name .. " - " .. tostring(module))
    end
  end
end
