local function read_file(path)
  local f = io.open(path, "rb")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  return content
end

local function get_module_name(path)
  local name = path:match("(.+)%.lua")
  if not name then return nil end
  return name:gsub("/", ".")
end

local bundle_path = "bundle.lua"
local out = io.open(bundle_path, "w")
out:write("-- Generated bundle by build.lua\n\n")

local dirs = {"modules", "utils"}
for _, dir in ipairs(dirs) do
  local handle = io.popen("find " .. dir .. " -name '*.lua'")
  for file in handle:lines() do
    local mod_name = get_module_name(file)
    if mod_name then
      local content = read_file(file)
      out:write(string.format("package.preload[%q] = function(...)\n", mod_name))
      out:write(content)
      out:write("\nend\n\n")
    end
  end
  handle:close()
end

local main_content = read_file("synch.lua")
out:write("-- Main entry\n")
out:write(main_content)
out:close()
print("Bundle created at " .. bundle_path)
