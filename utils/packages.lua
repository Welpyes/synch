local ffi = require("ffi")
local sys = require("utils.sys")

local Packages = {}

local prefix = os.getenv("PREFIX") or ""

--- Counts occurrences of a pattern in a file.
-- @param path string The path to the file.
-- @param pattern string The Lua pattern to match.
-- @return number The number of matches found.
local function count_file_matches(path, pattern)
  local file = io.open(path, "r")
  if not file then return 0 end
  
  local content = file:read("*a")
  file:close()
  
  local count = 0
  for _ in content:gmatch(pattern) do
    count = count + 1
  end
  return count
end

--- Counts directories in a path using opendir/readdir.
-- @param path string The path to the directory.
-- @return number The number of subdirectories found.
local function count_directories(path)
  local directory_handle = sys.opendir(path)
  if directory_handle == nil then return 0 end
  
  local count = 0
  while true do
    local entry = sys.readdir(directory_handle)
    if entry == nil then break end
    
    local entry_name = ffi.string(entry.d_name)
    if entry_name == "." or entry_name == ".." then
      goto continue
    end
    
    -- DT_DIR is typically 4 on Linux/Android
    if entry.d_type == 4 then
      count = count + 1
    end
    
    ::continue::
  end
  sys.closedir(directory_handle)
  return count
end

--- Gets package counts for various package managers.
-- @return table A table mapping package manager names to counts.
function Packages.get_info()
  local results = {}
  
  -- DPKG (Termux / Debian / Ubuntu)
  local dpkg_count = count_file_matches(prefix .. "/var/lib/dpkg/status", "Status: install ok installed")
  if dpkg_count > 0 then results.dpkg = dpkg_count end
  
  -- Pacman (Arch / Termux)
  local pacman_count = count_directories(prefix .. "/var/lib/pacman/local")
  if pacman_count > 0 then results.pacman = pacman_count end
  
  -- APK (Alpine / Termux)
  local apk_count = count_file_matches(prefix .. "/lib/apk/db/installed", "C:Q")
  if apk_count > 0 then results.apk = apk_count end

  -- Pkgtool (Slackware)
  local pkgtool_count = count_directories(prefix .. "/var/log/packages")
  if pkgtool_count > 0 then results.pkgtool = pkgtool_count end
  
  -- Flatpak (Standard Linux paths)
  local flatpak_count = count_directories("/var/lib/flatpak/app")
  local home_directory = os.getenv("HOME") or ""
  if home_directory ~= "" then
    flatpak_count = flatpak_count + count_directories(home_directory .. "/.local/share/flatpak/app")
  end
  if flatpak_count > 0 then results.flatpak = flatpak_count end
  
  -- Snap (Standard Linux paths)
  local snap_count = count_directories("/snap")
  if snap_count > 1 then 
    -- Subtract 1 to account for the 'bin' folder usually present in /snap
    results.snap = snap_count - 1 
  end
  
  -- Homebrew (Standard Linux paths)
  local brew_count = count_directories("/home/linuxbrew/.linuxbrew/Cellar")
  brew_count = brew_count + count_directories("/usr/local/Cellar")
  if brew_count > 0 then results.brew = brew_count end

  return results
end

return Packages
