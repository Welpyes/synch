local MemoryModule = {}
local ram_util = require("utils.get-ram")
local formatter = require("utils.formatter")

function MemoryModule.run(config, max_width)
  config = config or {}
  local info = ram_util.get_info()

  local icon = config.icon or "󰍛"
  local key = config.key or "Memory"
  local format = config.format or "{used} MiB / {total} MiB"
  
  local value = format:gsub("{used}", tostring(info.used))
                      :gsub("{total}", tostring(info.total))

  print(formatter.format(icon, key, value, config, max_width))
end

return MemoryModule
