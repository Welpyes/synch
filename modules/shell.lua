local ShellModule = {}
local shell_util = require("utils.get-shell")
local formatter = require("utils.formatter")

function ShellModule.run(config, max_width)
  config = config or {}
  local info = shell_util.get_info()

  local icon = config.icon or ""
  local key = config.key or "Shell"
  local format = config.format or "{name} {version}"
  
  local value = format:gsub("{name}", info.name):gsub("{version}", info.version)

  print(formatter.format(icon, key, value, config, max_width))
end

return ShellModule
