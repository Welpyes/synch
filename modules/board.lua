local BoardModule = {}
local board_util = require("utils.get-board")
local formatter = require("utils.formatter")

function BoardModule.run(config, max_width)
  config = config or {}
  local info = board_util.get_info()

  local icon = config.icon or "󱤓"
  local key = config.key or "Board"
  local format = config.format or "{manufacturer} {model}"
  
  local value = format:gsub("{manufacturer}", info.manufacturer)
                      :gsub("{model}", info.model)

  print(formatter.format(icon, key, value, config, max_width))
end

return BoardModule
