local ffi = require("ffi")

ffi.cdef[[
  struct utsname {
    char sysname[65];
    char nodename[65];
    char release[65];
    char version[65];
    char machine[65];
    char domainname[65];
  };
  int uname(struct utsname *buf);
]]

local SysInfo = {}

local cache_path = os.getenv("HOME") .. "/.cache/synch-cache.json"

local function read_file(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return content
end

local function write_file(path, content)
  -- Ensure directory exists
  local dir = path:match("(.*[/\\])")
  if dir then os.execute("mkdir -p " .. dir) end
  local file = io.open(path, "w")
  if not file then return end
  file:write(content)
  file:close()
end

-- Simple JSON parser for the specific structure requested
local function parse_cache(content)
  if not content then return nil end
  local info = {}
  for k, v in content:gmatch('"([^"]+)":%s*"([^"]+)"') do
    if k ~= "cache" and k ~= "sysinfo" then
      info[k] = v
    end
  end
  return next(info) and info or nil
end

local function serialize_cache(info)
  local lines = {
    '{',
    '  "cache": {',
    '    "sysinfo": {'
  }
  
  local fields = {
    "distro", "kernel", "kernel-version", "arch", "hostname"
  }
  
  local items = {}
  for _, k in ipairs(fields) do
    if info[k] then
      table.insert(items, string.format('      "%s": "%s"', k, info[k]))
    end
  end
  
  table.insert(lines, table.concat(items, ",\n"))
  table.insert(lines, '    }')
  table.insert(lines, '  }')
  table.insert(lines, '}')
  
  return table.concat(lines, "\n")
end

function SysInfo.get_info()
  local cache_content = read_file(cache_path)
  local cached_info = parse_cache(cache_content)

  if cached_info and cached_info.distro then
    return cached_info
  end

  -- Fetch fresh info
  local u = ffi.new("struct utsname[1]")
  ffi.C.uname(u)
  
  local handle = io.popen("uname -o")
  local distro = handle:read("*a"):gsub("%s+$", "")
  handle:close()

  local info = {
    distro = distro,
    kernel = ffi.string(u[0].sysname),
    ["kernel-version"] = ffi.string(u[0].release),
    arch = ffi.string(u[0].machine),
    hostname = ffi.string(u[0].nodename)
  }

  -- Save to cache
  write_file(cache_path, serialize_cache(info))
  
  return info
end

return SysInfo
