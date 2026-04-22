local UptimeModule = {}
local uptime_util = require("utils.get-uptime")
local colorizer = require("utils.colorizer")

function UptimeModule.run(config)
  config = config or {}
  local time_str = uptime_util.get_uptime()

  local icon = config.icon or ""
  local key = config.key or "Uptime"
  local format = config.format or "{time}"
  
  local icon_color = config["icon-color"] or "light yellow"
  local key_color = config["key-color"] or "white"
  local format_color = config["format-color"] or "light yellow"

  local value = format:gsub("{time}", time_str)

  local output = string.format("%s %s     %s", 
    colorizer.colorize(icon, icon_color),
    colorizer.colorize(key, key_color),
    colorizer.colorize(value, format_color)
  )
  
  print(output)
end

return UptimeModule
