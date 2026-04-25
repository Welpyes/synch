local ffi = require("ffi")
local sys = require("utils.sys")

local UptimeUtil = {}

function UptimeUtil.get_uptime()
  local info = ffi.new("struct sysinfo[1]")
  sys.sysinfo(info)

  local uptime = tonumber(info[0].uptime)
  local days  = math.floor(uptime / 86400)
  local hours = math.floor(uptime % 86400 / 3600)
  local mins  = math.floor(uptime % 3600 / 60)

  local parts = {}
  if days > 0 then table.insert(parts, days .. "d") end
  if hours > 0 then table.insert(parts, hours .. "h") end
  if mins > 0 or #parts == 0 then table.insert(parts, mins .. "m") end

  return table.concat(parts, " ")
end

return UptimeUtil
