-- Add logo directory to package path to allow requiring logo-gen
package.path = package.path .. ";synch/logo/?.lua"

local logo_gen = require("logo-gen")

local function get_os_name()
  local handle = io.popen("uname -o")
  local result = handle:read("*a")
  handle:close()
  return result:gsub("%s+$", "") -- Trim trailing whitespace/newline
end

local os_name = get_os_name()
if os_name == "" then
  os_name = "Unknown"
end

-- Font file path relative to the project root or adjusted for the module
local font_path = "synch/logo/smslant.flf"

local success, lines = pcall(logo_gen.generate, os_name, font_path)

if success then
  for _, line in ipairs(lines) do
    print(line)
  end
else
  print("Error generating logo: " .. tostring(lines))
  print("OS: " .. os_name)
end
