local OSModule = {}
local sys_info = require("utils.get-sysinfo")
local colorizer = require("utils.colorizer")

function OSModule.run(config)
  config = config or {}
  local info = sys_info.get_info()

  local icon = config.icon or ""
  local key = config.key or "OS"
  local format = config.format or "{name} {release} {version} {arch}"
  
  local icon_color = config["icon-color"] or "light green"
  local key_color = config["key-color"] or "white"
  local format_color = config["format-color"] or "light green"

  local value = format:gsub("{name}", info.distro)
                      :gsub("{release}", info.codename)
                      :gsub("{version}", info.version)
                      :gsub("{arch}", info.arch)

  local output = string.format("%s %s         %s", 
    colorizer.colorize(icon, icon_color),
    colorizer.colorize(key, key_color),
    colorizer.colorize(value, format_color)
  )
  
  print(output)
end

return OSModule
