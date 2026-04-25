local ffi = require("ffi")
local cache = require("utils.cache")
local sys = require("utils.sys")

local SysInfo = {}
local memoized_info = nil

local function get_android_prop(prop_name)
  local value = ffi.new("char[92]")
  local len = sys.__system_property_get(prop_name, value)
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
      v = v:gsub('^"(.*)"$', '%1')
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
  if memoized_info then return memoized_info end

  local u = ffi.new("struct utsname[1]")
  sys.uname(u)
  
  local hostname = ffi.string(u[0].nodename)
  local kernel_version = ffi.string(u[0].release)
  
  local cached = cache.get("sysinfo")
  local distro, kernel_name, arch
  
  if cached and cached.distro and cached.kernel and cached.arch then
    distro = cached.distro
    kernel_name = cached.kernel
    arch = cached.arch
  else
    kernel_name = ffi.string(u[0].sysname)
    arch = ffi.string(u[0].machine)
    
    local f = io.open("/system/lib64/ld-android.so", "r")
    if f then
      f:close()
      distro = "Android"
    else
      local os_info = parse_os_release()
      distro = os_info.name
    end
    
    cache.set("sysinfo", { distro = distro, kernel = kernel_name, arch = arch })
  end

  -- These are never cached and always fetched fresh
  local version, codename
  local is_android = (distro == "Android")
  
  if is_android then
    version = get_android_prop("ro.com.google.gmsversion") or ""
    codename = get_android_prop("ro.build.version.all_codenames") or ""
  else
    local os_info = parse_os_release()
    version = os_info.version
    codename = os_info.codename
  end

  memoized_info = {
    distro = distro,
    version = version,
    codename = codename,
    is_android = is_android,
    kernel = kernel_name,
    ["kernel-version"] = kernel_version,
    arch = arch,
    hostname = hostname
  }

  return memoized_info
end

return SysInfo
