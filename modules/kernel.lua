local KernelModule = {}
local sys_info = require("utils.get-sysinfo")
local formatter = require("utils.formatter")

function KernelModule.run(config, max_width)
  config = config or {}
  local info = sys_info.get_info()

  local icon = config.icon or ""
  local key = config.key or "Kernel"
  local format = config.format or "{name} {version}"
  
  local value = format:gsub("{name}", info.kernel):gsub("{version}", info["kernel-version"])

  print(formatter.format(icon, key, value, config, max_width))
end

return KernelModule
