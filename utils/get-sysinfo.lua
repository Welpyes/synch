local ffi = require("ffi")
local cache = require("utils.cache")

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

function SysInfo.get_info()
  local cached_info = cache.get("sysinfo")

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
  cache.set("sysinfo", info)
  
  return info
end

return SysInfo
