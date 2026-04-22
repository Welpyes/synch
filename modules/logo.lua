local LogoModule = {}
local logo_gen = require("utils.logo-gen")
local colorizer = require("utils.colorizer")
local sys_info = require("utils.get-sysinfo")

-- Get base directory of the project
local script_path = debug.getinfo(1).source:match("@?(.*)")
local module_dir = script_path:match("(.*[/\\])") or "./"
local base_dir = module_dir:gsub("modules[/\\]$", "")

function LogoModule.run(config)
  config = config or {}
  
  local info = sys_info.get_info()
  local format = config.format or "{distro}"
  
  -- Handle manual text override if present, otherwise use format
  local text = config.text or format:gsub("{distro}", info.distro)
  
  if text == "" then text = "Unknown" end

  local color = config.color or "blue"
  local font_path = base_dir .. "font/smslant.flf"

  local success, lines = pcall(logo_gen.generate, text, font_path)

  if success then
    for _, line in ipairs(lines) do
      print(colorizer.colorize(line, color))
    end
  else
    print(colorizer.colorize("Error generating logo: " .. tostring(lines), "red"))
  end
end

return LogoModule
