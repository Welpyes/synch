local ffi = require("ffi")
local sys = require("utils.sys")

local Shell = {}
local memoized_shell_info = nil

local function get_version_from_pacman(shell_name)
  local terminal_prefix = os.getenv("PREFIX") or ""
  local database_search_paths = { terminal_prefix .. "/var/lib/pacman/local/", "/var/lib/pacman/local/" }
  
  for _, database_path in ipairs(database_search_paths) do
    local directory_handle = sys.opendir(database_path)
    if directory_handle ~= nil then
      local version_found = nil
      while true do
        local entry = sys.readdir(directory_handle)
        if entry == nil then break end
        
        local entry_name = ffi.string(entry.d_name)
        if entry_name:sub(1, #shell_name + 1) == shell_name .. "-" then
          version_found = entry_name:sub(#shell_name + 2)
          break
        end
      end
      sys.closedir(directory_handle)
      if version_found then return version_found end
    end
  end
  return nil
end

function Shell.get_info()
  if memoized_shell_info then return memoized_shell_info end

  local parent_pid = sys.getppid()
  local executable_proc_path = string.format("/proc/%d/exe", parent_pid)
  local path_buffer = ffi.new("char[256]")
  local path_length = sys.readlink(executable_proc_path, path_buffer, 255)
  
  local full_executable_path = "/bin/sh"
  local shell_name = "sh"
  
  if path_length > 0 then
    full_executable_path = ffi.string(path_buffer, path_length)
    shell_name = full_executable_path:match("([^/]+)$") or "sh"
  end

  -- 1. Check common environment variables
  local shell_version_variables = {
    bash = "BASH_VERSION",
    zsh = "ZSH_VERSION",
    mksh = "KSH_VERSION",
    ksh = "KSH_VERSION"
  }
  
  local environment_variable_name = shell_version_variables[shell_name]
  if environment_variable_name then
    local version_pointer = sys.getenv(environment_variable_name)
    if version_pointer ~= nil then
      memoized_shell_info = { 
        name = shell_name, 
        version = ffi.string(version_pointer):match("^[%d%.]+") 
      }
      return memoized_shell_info
    end
  end

  -- 2. Scan Pacman database
  local pacman_version = get_version_from_pacman(shell_name)
  if pacman_version then
    memoized_shell_info = { name = shell_name, version = pacman_version }
    return memoized_shell_info
  end

  -- 3. Fallback: Execute shell for version
  local version_command
  if shell_name == "bash" or shell_name == "zsh" then
    version_command = full_executable_path .. " --version 2>&1"
  elseif shell_name == "mksh" or shell_name == "sh" then
    version_command = full_executable_path .. " -c 'echo $KSH_VERSION$POSIXLY_CORRECT' 2>&1"
  else
    version_command = full_executable_path .. " --version 2>&1"
  end

  local handle = io.popen(version_command)
  if handle then
    local output = handle:read("*a")
    handle:close()
    local version = output:match("(%d+%.[%d%.%-]+)") or "unknown"
    memoized_shell_info = { name = shell_name, version = version }
    return memoized_shell_info
  end

  memoized_shell_info = { name = shell_name, version = "unknown" }
  return memoized_shell_info
end

return Shell
