local OSModule = {}
local sys_info = require("utils.get-sysinfo")
local formatter = require("utils.formatter")

function OSModule.run(config, max_width)
  config = config or {}
  local info = sys_info.get_info()

  local icon = config.icon or ""
  local key = config.key or "OS"
  local format = config.format or "{name} {release} {version} {arch}"
  
  local value = format:gsub("{name}", info.distro)
                      :gsub("{release}", info.codename)
                      :gsub("{version}", info.version)
                      :gsub("{arch}", info.arch)

  print(formatter.format(icon, key, value, config, max_width))
end

return OSModule
