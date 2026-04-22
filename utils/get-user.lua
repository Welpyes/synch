local ffi = require("ffi")

ffi.cdef[[
  typedef unsigned int uid_t;
  uid_t getuid(void);
  struct passwd {
    char *pw_name;
    char *pw_passwd;
    uid_t pw_uid;
    unsigned int pw_gid;
    char *pw_gecos;
    char *pw_dir;
    char *pw_shell;
  };
  struct passwd *getpwuid(uid_t uid);
]]

local UserUtil = {}

function UserUtil.get_username()
  local pw = ffi.C.getpwuid(ffi.C.getuid())
  if pw ~= nil then
    return ffi.string(pw.pw_name)
  end
  return os.getenv("USER") or "unknown"
end

return UserUtil
