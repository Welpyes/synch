local ffi = require("ffi")
local sys = require("utils.sys")

local UserUtil = {}

function UserUtil.get_username()
  local pw = sys.getpwuid(sys.getuid())
  if pw ~= nil then
    return ffi.string(pw.pw_name)
  end
  return os.getenv("USER") or "unknown"
end

return UserUtil
