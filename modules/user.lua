local UserModule = {}
local user_util = require("utils.get-user")
local sys_info = require("utils.get-sysinfo")
local formatter = require("utils.formatter")

function UserModule.run(config, max_width)
  config = config or {}
  local username = user_util.get_username()
  local info = sys_info.get_info()
  local hostname = info.hostname or "unknown"

  local icon = config.icon or ""
  local key = config.key or "User"
  local format = config.format or "{user}@{host}"
  
  local value = format:gsub("{user}", username):gsub("{host}", hostname)

  print(formatter.format(icon, key, value, config, max_width))
end

return UserModule
