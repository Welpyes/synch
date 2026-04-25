local WMModule = {}
local wm_de_util = require("utils.get-wm-de")
local formatter = require("utils.formatter")

function WMModule.run(config, max_width)
  config = config or {}
  local info = wm_de_util.get_info()

  if info.wm == "Unknown" then return end

  local icon = config.icon or ""
  local key = config.key or "WM"
  local format = config.format or "{wm}"
  
  local value = format:gsub("{wm}", info.wm)

  print(formatter.format(icon, key, value, config, max_width))
end

return WMModule
