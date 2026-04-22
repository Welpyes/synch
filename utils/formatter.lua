local Formatter = {}
local colorizer = require("utils.colorizer")

function Formatter.format(icon, key, value, config, max_key_width)
  local icon_color = config["icon-color"] or "white"
  local key_color = config["key-color"] or "white"
  local format_color = config["format-color"] or "white"
  
  -- Use provided max_key_width or default to a reasonable value
  local width = max_key_width or 12
  local spacing = string.rep(" ", width - #key + 2) -- +2 for extra breathing room

  local colored_icon = colorizer.colorize(icon, icon_color)
  local colored_key = colorizer.colorize(key, key_color)
  local colored_value = colorizer.colorize(value, format_color)

  return string.format("%s %s%s%s", colored_icon, colored_key, spacing, colored_value)
end

return Formatter
