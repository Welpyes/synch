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

local KernelUtil = {}

function KernelUtil.get_info()
  local u = ffi.new("struct utsname[1]")
  ffi.C.uname(u)
  return {
    name = ffi.string(u[0].sysname),
    version = ffi.string(u[0].release)
  }
end

return KernelUtil
