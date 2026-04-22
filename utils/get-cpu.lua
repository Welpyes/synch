local sys_info = require("utils.get-sysinfo")

local CPUUtil = {}
local memoized_cpu = nil

local implementers = {
  ["0x41"] = "ARM",
  ["0x53"] = "Samsung",
  ["0x51"] = "Qualcomm",
  ["0x50"] = "Apple",
}

local cpu_parts = {
  ["0x41"] = {
    ["0xd05"] = "Cortex-A55",
    ["0xd09"] = "Cortex-A73",
    ["0xd0b"] = "Cortex-A76",
    ["0xd0a"] = "Cortex-A75",
  },
  ["0x53"] = {
    ["0x002"] = "Exynos-M3",
    ["0x001"] = "Exynos-M1",
  },
}

local function get_max_freq(policy)
  local f = io.open("/sys/devices/system/cpu/cpufreq/policy" .. policy .. "/cpuinfo_max_freq", "r")
  if not f then
    -- Try another common path
    f = io.open("/sys/devices/system/cpu/cpu" .. policy .. "/cpufreq/scaling_max_freq", "r")
  end
  if f then
    local v = tonumber(f:read("*l"))
    f:close()
    return v and (v / 1000000) or nil
  end
  return nil
end

local function get_android_cpu()
  local f = io.open("/proc/cpuinfo", "r")
  if not f then return "Unknown" end
  local cores = 0
  local clusters = {}
  local seen_order = {}
  local seen = {}
  local cur_impl, cur_part

  for line in f:lines() do
    if line:match("^processor") then cores = cores + 1 end
    local impl = line:match("^CPU implementer%s*:%s*(%S+)")
    local part = line:match("^CPU part%s*:%s*(%S+)")
    if impl then cur_impl = impl end
    if part then cur_part = part end
    if cur_impl and cur_part then
      local key = cur_impl .. cur_part
      local impl_name = implementers[cur_impl] or cur_impl
      local part_name = (cpu_parts[cur_impl] and cpu_parts[cur_impl][cur_part]) or cur_part
      if not seen[key] then
        seen[key] = true
        table.insert(seen_order, key)
        clusters[key] = { part = part_name, count = 0, first_core = cores - 1 }
      end
      clusters[key].count = clusters[key].count + 1
      cur_impl, cur_part = nil, nil
    end
  end
  f:close()

  local parts_str = {}
  for _, key in ipairs(seen_order) do
    local c = clusters[key]
    local freq = get_max_freq(c.first_core)
    local freq_str = freq and string.format(" @ %.2f GHz", freq) or ""
    table.insert(parts_str, c.part .. " x" .. c.count .. freq_str)
  end

  return table.concat(parts_str, " + ") .. " (" .. cores .. " cores)"
end

local function get_linux_cpu()
  local f = io.open("/proc/cpuinfo", "r")
  if not f then return "Unknown" end
  local model_name = "Unknown"
  local cores = 0
  for line in f:lines() do
    if line:match("^model name") then
      model_name = line:match("^model name%s*:%s*(.*)$")
    elseif line:match("^processor") then
      cores = cores + 1
    end
  end
  f:close()
  
  -- Try to get freq for cpu0 as representative
  local freq = get_max_freq(0)
  local freq_str = freq and string.format(" @ %.2f GHz", freq) or ""
  
  return model_name .. freq_str .. " (" .. cores .. " cores)"
end

function CPUUtil.get_cpu()
  if memoized_cpu then return memoized_cpu end
  
  local info = sys_info.get_info()
  if info.is_android then
    memoized_cpu = get_android_cpu()
  else
    memoized_cpu = get_linux_cpu()
  end
  
  return memoized_cpu
end

return CPUUtil
