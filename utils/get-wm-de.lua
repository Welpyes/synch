local ffi = require("ffi")
local sys_info = require("utils.get-sysinfo")
local sys = require("utils.sys")

local WMDE = {}
local memoized_info = nil

-- Order matters: specialized or newer WMs/compositors first
local known_wms = {
  "labwc", "bspwm", "i3", "sway", "openbox", "kwin", "mutter", "muffin", "marco", "xfwm4",
  "awesome", "dwm", "spectrwm", "ratpoison", "herbstluftwm", "fluxbox",
  "blackbox", "waimea", "fvwm", "sawfish", "icewm", "afterstep",
  "enlightenment", "qtile", "xmonad", "hyprland", "weston", "wayfire", "niri", "mangowc"
}

local function get_android_prop(prop_name)
  local value = ffi.new("char[92]")
  local len = sys.__system_property_get(prop_name, value)
  if len > 0 then return ffi.string(value, len) end
  return nil
end

local function get_wm_from_proc()
  local dir = sys.opendir("/proc")
  if dir == nil then return nil end

  local found_wm = nil

  while true do
    local entry = sys.readdir(dir)
    if entry == nil then break end
    local name = ffi.string(entry.d_name)
    
    if name:match("^%d+$") then
      local cmdline_path = "/proc/" .. name .. "/cmdline"
      local f = io.open(cmdline_path, "r")
      if f then
        local content = f:read("*a")
        f:close()
        local proc_name = content:match("^([^%z]+)")
        if proc_name then
          local base_name = proc_name:match("([^/]+)$")
          for _, wm in ipairs(known_wms) do
            if base_name == wm then
              -- Prioritize if we find a Wayland compositor while in Wayland
              if os.getenv("WAYLAND_DISPLAY") and (wm == "labwc" or wm == "sway" or wm == "hyprland") then
                found_wm = wm
                break
              end
              -- Otherwise store and keep looking for better match
              if not found_wm then found_wm = wm end
            end
          end
        end
      end
    end
    if found_wm and (found_wm == "labwc" or found_wm == "hyprland") then break end
  end
  sys.closedir(dir)
  return found_wm
end

local function get_de_from_env()
  local envs = {
    "XDG_CURRENT_DESKTOP",
    "XDG_SESSION_DESKTOP",
    "CURRENT_DESKTOP",
    "SESSION_DESKTOP",
    "DESKTOP_SESSION"
  }
  for _, env in ipairs(envs) do
    local val = os.getenv(env)
    if val and val ~= "" then
      return val
    end
  end
  return nil
end

local function get_android_de()
  local de_name = get_android_prop("ro.mi.os.version.name")
  if de_name then
    local version = get_android_prop("ro.build.version.incremental") or ""
    if version:find("^OS") then return "HyperOS " .. version:sub(3) end
    if version:find("^V") then return "MiUI " .. version:sub(2) end
    return "MiUI"
  end

  local props = {
    {"ro.vivo.os.build.display.id", "OriginOS"},
    {"ro.build.version.magic", "MagicUI"},
    {"ro.build.version.emui", "EMUI"},
    {"ro.build.version.oplusrom", "ColorOS"},
    {"ro.oxygen.version", "OxygenOS"},
    {"ro.build.display.id", nil}
  }

  for _, prop in ipairs(props) do
    local val = get_android_prop(prop[1])
    if val then
      if prop[2] then return prop[2] .. " " .. val end
      return val
    end
  end
  return nil
end

function WMDE.get_info()
  if memoized_info then return memoized_info end

  local de = get_de_from_env()
  local wm = nil
  
  local display = os.getenv("DISPLAY")
  local wayland_display = os.getenv("WAYLAND_DISPLAY")

  if display or wayland_display then
    wm = get_wm_from_proc()
    if wm then
      wm = wm .. (wayland_display and " (Wayland)" or " (X11)")
    else
      wm = wayland_display and "Wayland" or "X11"
    end
  end

  if not wm and os.getenv("TERMUX_VERSION") then
    wm = "WindowManager"
  end

  local info = sys_info.get_info()
  if info.is_android and not de then
    de = get_android_de()
  end

  memoized_info = {
    de = de or "Unknown",
    wm = wm or "Unknown"
  }
  return memoized_info
end

return WMDE
