local KernelModule = {}
local sys_info = require("utils.get-sysinfo")
local colorizer = require("utils.colorizer")

function KernelModule.run(config)
  config = config or {}
  local info = sys_info.get_info()

  local icon = config.icon or ""
  local key = config.key or "Kernel"
  local format = config.format or "{name} {version}"
  
  local icon_color = config["icon-color"] or "light blue"
  local key_color = config["key-color"] or "white"
  local format_color = config["format-color"] or "light blue"

  -- Map new sysinfo keys to legacy template keys
  local value = format:gsub("{name}", info.kernel):gsub("{version}", info["kernel-version"])

  local output = string.format("%s %s     %s", 
    colorizer.colorize(icon, icon_color),
    colorizer.colorize(key, key_color),
    colorizer.colorize(value, format_color)
  )
  
  print(output)
end

return KernelModule
