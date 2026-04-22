local LogoModule = {}
local logo_gen = require("utils.logo-gen")
local colorizer = require("utils.colorizer")
local sys_info = require("utils.get-sysinfo")
local font_data = require("utils.font-data")

function LogoModule.run(config)
  config = config or {}
  
  local info = sys_info.get_info()
  local format = config.format or "{distro}"
  local text = config.text or format:gsub("{distro}", info.distro)
  
  if text == "" then text = "Unknown" end

  local color = config.color or "blue"
  
  -- Use embedded font data by default, allow override if font path is provided
  local font_source = config.font and config.font or font_data

  local success, lines = pcall(logo_gen.generate, text, font_source)

  if success then
    for _, line in ipairs(lines) do
      print(colorizer.colorize(line, color))
    end
  else
    print(colorizer.colorize("Error generating logo: " .. tostring(lines), "red"))
  end
end

return LogoModule
