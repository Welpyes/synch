local RAMUtil = {}

function RAMUtil.get_info()
  local file = io.open("/proc/meminfo", "r")
  if not file then return { used = 0, total = 0 } end

  local mem_total, mem_available = 0, 0
  for line in file:lines() do
    local key, value = line:match("^([^:]+):%s+(%d+)")
    if key == "MemTotal" then
      mem_total = tonumber(value)
    elseif key == "MemAvailable" then
      mem_available = tonumber(value)
    end
    if mem_total > 0 and mem_available > 0 then break end
  end
  file:close()

  local mem_used = mem_total - mem_available
  
  return {
    used = math.floor(mem_used / 1024),
    total = math.floor(mem_total / 1024)
  }
end

return RAMUtil
