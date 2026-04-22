local UptimeModule = {}
local uptime_util = require("utils.get-uptime")
local formatter = require("utils.formatter")

function UptimeModule.run(config, max_width)
  config = config or {}
  local time_str = uptime_util.get_uptime()

  local icon = config.icon or ""
  local key = config.key or "Uptime"
  local format = config.format or "{time}"
  
  local value = format:gsub("{time}", time_str)

  print(formatter.format(icon, key, value, config, max_width))
end

return UptimeModule
