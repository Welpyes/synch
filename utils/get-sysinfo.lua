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
  int __system_property_get(const char *name, char *value);
]]

local SysInfo = {}

local function get_android_prop(prop_name)
  local value = ffi.new("char[92]")
  local len = ffi.C.__system_property_get(prop_name, value)
  if len > 0 then return ffi.string(value, len) end
  return nil
end

local function parse_os_release()
  local info = { name = "Linux", version = "", codename = "" }
  local file = io.open("/etc/os-release", "r")
  if not file then return info end
  
  for line in file:lines() do
    local k, v = line:match('^([%w_]+)=(.*)$')
    if k then
      v = v:gsub('^"(.*)"$', '%1') -- strip quotes
      if k == "NAME" then info.name = v
      elseif k == "VERSION_ID" then info.version = v
      elseif k == "VERSION_CODENAME" then info.codename = v
      end
    end
  end
  file:close()
  return info
end

function SysInfo.get_info()
  local cached_info = cache.get("sysinfo")
  -- If cached_info exists and has 'codename' (new field), return it.
  -- This forces a refresh if the old cache format (without codename) exists.
  if cached_info and cached_info.distro and cached_info.codename then
    return cached_info
  end

  -- Fetch fresh info
  local u = ffi.new("struct utsname[1]")
  ffi.C.uname(u)
  
  local distro, version, codename
  local f = io.open("/system/lib64/ld-android.so", "r")
  if f then
    f:close()
    distro = "Android"
    version = get_android_prop("ro.com.google.gmsversion") or ""
    codename = get_android_prop("ro.build.version.all_codenames") or ""
  else
    local os_info = parse_os_release()
    distro = os_info.name
    version = os_info.version
    codename = os_info.codename
  end

  local info = {
    distro = distro,
    version = version,
    codename = codename,
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
