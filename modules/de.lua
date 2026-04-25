local DEModule = {}
local wm_de_util = require("utils.get-wm-de")
local formatter = require("utils.formatter")

function DEModule.run(config, max_width)
  config = config or {}
  local info = wm_de_util.get_info()
  
  if info.de == "Unknown" then return end

  local icon = config.icon or ""
  local key = config.key or "DE"
  local format = config.format or "{de}"
  
  local value = format:gsub("{de}", info.de)

  print(formatter.format(icon, key, value, config, max_width))
end

return DEModule
