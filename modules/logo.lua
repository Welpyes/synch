local LogoModule = {}
local logo_gen = require("utils.logo-gen")
local colorizer = require("utils.colorizer")

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
  local font_path = "synch/font/smslant.flf"

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
