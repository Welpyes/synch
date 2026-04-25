-- Get the directory where synch.lua lives
local script_path = debug.getinfo(1).source:match("@?(.*)")
local script_dir = script_path:match("(.*[/\\])") or "./"

-- Add project directories to package path relative to the script location
package.path = package.path .. ";" .. script_dir .. "?.lua"

local toml = require("utils.toml")

local function read_file(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end
	local content = file:read("*a")
	file:close()
	return content
end

-- 1. Configuration Loading Logic
local home = os.getenv("HOME") or ""
local config_paths = {
	home .. "/.config/synch/config.toml",
	script_dir .. "config.toml",
}

local config_content = nil
for _, path in ipairs(config_paths) do
	config_content = read_file(path)
	if config_content then
		break
	end
end

-- Default fallback config if no file found
local default_config = {
	global = {
		modules = { "logo", "user:user", "os", "de", "wm", "host", "kernel", "uptime", "shell", "cpu", "gpu", "packages" },
	},
	logo = { color = "blue", format = "{distro}" },
	["user:user"] = {
		key = "User",
		icon = "",
		["icon-color"] = "light magenta",
		["format-color"] = "light magenta",
		format = "{user}",
	},
	os = {
		key = "OS",
		icon = "",
		["icon-color"] = "light green",
		["format-color"] = "light green",
		format = "{name} {release} {version} {arch}",
	},
	de = {
		key = "DE",
		icon = "",
		["icon-color"] = "light blue",
		["format-color"] = "light blue",
		format = "{de}",
	},
	wm = {
		key = "WM",
		icon = "",
		["icon-color"] = "light blue",
		["format-color"] = "light blue",
		format = "{wm}",
	},
	host = {
		key = "Host",
		icon = "󱤓",
		["icon-color"] = "light cyan",
		["format-color"] = "light cyan",
		format = "{manufacturer} {model}",
	},
	kernel = {
		key = "Kernel",
		icon = "",
		["icon-color"] = "light blue",
		["format-color"] = "light blue",
		format = "{name} {version}",
	},
	uptime = {
		key = "Uptime",
		icon = "",
		["icon-color"] = "light yellow",
		["format-color"] = "light yellow",
		format = "{time}",
	},
	shell = {
		key = "Shell",
		icon = "",
		["icon-color"] = "light blue",
		["format-color"] = "light blue",
		format = "{name} {version}",
	},
	cpu = { key = "Cpu", icon = "", ["icon-color"] = "red", ["format-color"] = "red", format = "{cpu}" },
	gpu = {
		key = "Gpu",
		icon = "󰢮",
		["icon-color"] = "light yellow",
		["format-color"] = "light yellow",
		format = "{name}",
	},
	packages = {
		key = "Packages",
		icon = "󰏖",
		["icon-color"] = "light yellow",
		["format-color"] = "light yellow",
		format = "{all} ({detailed})",
	},
}

local config = config_content and toml.parse(config_content) or default_config

-- Pre-load and calculate max key width
local loaded_modules = {}
local max_key_width = 0
if config.global and config.global.modules then
	for _, entry in ipairs(config.global.modules) do
		local module_name = entry:match("^([^:]+)")
		local module_config = config[entry]

		if not loaded_modules[module_name] then
			loaded_modules[module_name] = require("modules." .. module_name)
		end

		if module_config and module_config.key then
			max_key_width = math.max(max_key_width, #module_config.key)
		end
	end
end

-- Execution
if config.global and config.global.modules then
	for _, entry in ipairs(config.global.modules) do
		local module_name = entry:match("^([^:]+)")
		local module = loaded_modules[module_name]
		if module then
			module.run(config[entry], max_key_width)
		end
	end
end
