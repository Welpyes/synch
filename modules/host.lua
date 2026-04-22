local HostModule = {}
local host_util = require("utils.get-host")
local formatter = require("utils.formatter")

function HostModule.run(config, max_width)
  config = config or {}
  local info = host_util.get_info()

  local icon = config.icon or "󱤓"
  local key = config.key or "Host"
  local format = config.format or "{manufacturer} {model}"
  
  local value = format:gsub("{manufacturer}", info.manufacturer)
                      :gsub("{model}", info.model)

  print(formatter.format(icon, key, value, config, max_width))
end

return HostModule
