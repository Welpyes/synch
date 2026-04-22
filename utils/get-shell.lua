local ffi = require("ffi")

ffi.cdef[[
    typedef struct __dirstream DIR;
    struct dirent {
        long d_ino;
        long d_off;
        unsigned short d_reclen;
        unsigned char d_type;
        char d_name[256];
    };
    int getppid(void);
    ssize_t readlink(const char *path, char *buf, size_t bufsiz);
    DIR *opendir(const char *name);
    struct dirent *readdir(DIR *dirp);
    int closedir(DIR *dirp);
    char *getenv(const char *name);
]]

local ShellUtil = {}
local memoized_shell = nil

function ShellUtil.get_info()
    if memoized_shell then return memoized_shell end

    local ppid = ffi.C.getppid()
    local proc_path = string.format("/proc/%d/exe", ppid)
    local buf = ffi.new("char[256]")
    local len = ffi.C.readlink(proc_path, buf, 255)
    
    local full_path = "/bin/sh"
    local shell_name = "sh"
    
    if len > 0 then
        full_path = ffi.string(buf, len)
        shell_name = full_path:match("([^/]+)$") or "sh"
    end

    -- 1. Check common env vars (0ms)
    local version_vars = {
        bash = "BASH_VERSION",
        zsh = "ZSH_VERSION",
        mksh = "KSH_VERSION",
        ksh = "KSH_VERSION"
    }
    
    local env_var = version_vars[shell_name]
    if env_var then
        local ver_ptr = ffi.C.getenv(env_var)
        if ver_ptr ~= nil then
            memoized_shell = { name = shell_name, version = ffi.string(ver_ptr):match("^[%d%.]+") }
            return memoized_shell
        end
    end

    -- 2. Scan Pacman DB for that shell's version (12-20ms)
    local function get_version_from_pacman(name)
        local prefix = os.getenv("PREFIX") or ""
        local db_paths = { prefix .. "/var/lib/pacman/local/", "/var/lib/pacman/local/" }
        
        for _, db_path in ipairs(db_paths) do
            local dir = ffi.C.opendir(db_path)
            if dir ~= nil then
                local version = nil
                while true do
                    local entry = ffi.C.readdir(dir)
                    if entry == nil then break end
                    
                    local d_name = ffi.string(entry.d_name)
                    if d_name:sub(1, #name + 1) == name .. "-" then
                        version = d_name:sub(#name + 2)
                        break
                    end
                end
                ffi.C.closedir(dir)
                if version then return version end
            end
        end
        return nil
    end

    local pacman_ver = get_version_from_pacman(shell_name)
    if pacman_ver then
        memoized_shell = { name = shell_name, version = pacman_ver }
        return memoized_shell
    end

    -- 3. Fallback Path: One-shot exec (~20-30ms)
    local cmd
    if shell_name == "bash" or shell_name == "zsh" then
        cmd = full_path .. " --version 2>&1"
    elseif shell_name == "mksh" or shell_name == "sh" then
        cmd = full_path .. " -c 'echo $KSH_VERSION$POSIXLY_CORRECT' 2>&1"
    else
        cmd = full_path .. " --version 2>&1"
    end

    local f = io.popen(cmd)
    if f then
        local output = f:read("*a")
        f:close()
        local version = output:match("(%d+%.[%d%.%-]+)") or "unknown"
        memoized_shell = { name = shell_name, version = version }
        return memoized_shell
    end

    memoized_shell = { name = shell_name, version = "unknown" }
    return memoized_shell
end

return ShellUtil
