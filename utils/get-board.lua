local ffi = require("ffi")

ffi.cdef[[
  int __system_property_get(const char *name, char *value);
]]

local BoardUtil = {}
local memoized_board = nil

local function get_android_prop(prop_name)
  local value = ffi.new("char[92]")
  local len = ffi.C.__system_property_get(prop_name, value)
  if len > 0 then return ffi.string(value, len) end
  return nil
end

local function read_file_line(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local line = file:read("*l")
  file:close()
  return line and line:gsub("%s+$", "") or nil
end

function BoardUtil.get_info()
  if memoized_board then return memoized_board end

  local is_android = pcall(function() return ffi.C.__system_property_get end)
  
  if is_android then
    local manufacturer = get_android_prop("ro.product.manufacturer") or "Unknown"
    local model = get_android_prop("ro.product.model") or "Unknown"
    memoized_board = {
      manufacturer = manufacturer,
      model = model
    }
  else
    local manufacturer = read_file_line("/sys/class/dmi/id/board_vendor") or "Unknown"
    local model = read_file_line("/sys/class/dmi/id/board_name") or "Unknown"
    memoized_board = {
      manufacturer = manufacturer,
      model = model
    }
  end
  return memoized_board
end

return BoardUtil
