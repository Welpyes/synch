local Colorizer = {}

local ansi_colors = {
  black         = 30,
  red           = 31,
  green         = 32,
  yellow        = 33,
  blue          = 34,
  magenta       = 35,
  cyan          = 36,
  white         = 37,
  
  ["light black"]   = 90,
  ["light red"]     = 91,
  ["light green"]   = 92,
  ["light yellow"]  = 93,
  ["light blue"]    = 94,
  ["light magenta"] = 95,
  ["light cyan"]    = 96,
  ["light white"]   = 97,
  
  reset         = 0,
}

local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

function Colorizer.colorize(text, color)
  if not color then return text end

  if ansi_colors[color] then
    return string.format("\27[%dm%s\27[0m", ansi_colors[color], text)
  elseif color:match("^#%x%x%x%x%x%x$") then
    local r, g, b = hex_to_rgb(color)
    return string.format("\27[38;2;%d;%d;%dm%s\27[0m", r, g, b, text)
  end

  return text
end

return Colorizer
