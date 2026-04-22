local UserModule = {}
local user_util = require("utils.get-user")
local sys_info = require("utils.get-sysinfo")
local colorizer = require("utils.colorizer")

function UserModule.run(config)
  config = config or {}
  local username = user_util.get_username()
  local info = sys_info.get_info()
  local hostname = info.hostname or "unknown"

  local icon = config.icon or ""
  local key = config.key or "User"
  local format = config.format or "{user}@{host}"
  
  local icon_color = config["icon-color"] or "light magenta"
  local key_color = config["key-color"] or "white"
  local format_color = config["format-color"] or "light magenta"

  local value = format:gsub("{user}", username):gsub("{host}", hostname)

  local output = string.format("%s %s       %s", 
    colorizer.colorize(icon, icon_color),
    colorizer.colorize(key, key_color),
    colorizer.colorize(value, format_color)
  )
  
  print(output)
end

return UserModule
