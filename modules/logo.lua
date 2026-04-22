local LogoModule = {}
local logo_gen = require("utils.logo-gen")
local colorizer = require("utils.colorizer")

-- Get base directory of the project
local script_path = debug.getinfo(1).source:match("@?(.*)")
local module_dir = script_path:match("(.*[/\\])") or "./"
local base_dir = module_dir:gsub("modules[/\\]$", "")

local function get_os_name()
  local handle = io.popen("uname -o")
  local result = handle:read("*a")
  handle:close()
  return result:gsub("%s+$", "")
end

function LogoModule.run(config)
  config = config or {}
  local text = config.text or get_os_name()
  if text == "" then text = "Unknown" end

  local color = config.color or "blue"
  -- Construct font path relative to project base
  local font_path = base_dir .. "font/smslant.flf"

  local success, lines = pcall(logo_gen.generate, text, font_path)

  if success then
    for _, line in ipairs(lines) do
      print(colorizer.colorize(line, color))
    end
  else
    print(colorizer.colorize("Error generating logo: " .. tostring(lines), "red"))
    print(colorizer.colorize("Looked for font at: " .. font_path, "red"))
  end
end

return LogoModule
