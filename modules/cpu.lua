local CPUModule = {}
local cpu_util = require("utils.get-cpu")
local formatter = require("utils.formatter")

function CPUModule.run(config, max_width)
  config = config or {}
  local cpu_str = cpu_util.get_cpu()

  local icon = config.icon or ""
  local key = config.key or "Cpu"
  local format = config.format or "{cpu}"
  
  local value = format:gsub("{cpu}", cpu_str)

  print(formatter.format(icon, key, value, config, max_width))
end

return CPUModule
