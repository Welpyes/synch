local ffi = require("ffi")

pcall(ffi.cdef, [[
  typedef unsigned int uid_t;
  typedef long ssize_t;
  
  typedef struct __dirstream DIR;
  struct dirent {
    long d_ino;
    long d_off;
    unsigned short d_reclen;
    unsigned char d_type;
    char d_name[256];
  };

  struct passwd {
    char *pw_name;
    char *pw_passwd;
    uid_t pw_uid;
    unsigned int pw_gid;
    char *pw_gecos;
    char *pw_dir;
    char *pw_shell;
  };

  struct utsname {
    char sysname[65];
    char nodename[65];
    char release[65];
    char version[65];
    char machine[65];
    char domainname[65];
  };

  struct sysinfo {
    long uptime;
    unsigned long loads[3];
    unsigned long totalram;
    unsigned long freeram;
    unsigned long sharedram;
    unsigned long bufferram;
    unsigned long totalswap;
    unsigned long freeswap;
    unsigned short procs;
    unsigned long totalhigh;
    unsigned long freehigh;
    unsigned int mem_unit;
    char _f[20 - 2 * sizeof(long) - sizeof(int)];
  };

  int getppid(void);
  uid_t getuid(void);
  struct passwd *getpwuid(uid_t uid);
  int uname(struct utsname *buf);
  int sysinfo(struct sysinfo *info);
  ssize_t readlink(const char *path, char *buf, size_t bufsiz);
  DIR *opendir(const char *name);
  struct dirent *readdir(DIR *dirp);
  int closedir(DIR *dirp);
  char *getenv(const char *name);
  int __system_property_get(const char *name, char *value);
]])

return ffi.C
