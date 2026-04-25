local PackagesModule = {}
local packages_util = require("utils.packages")
local formatter = require("utils.formatter")

function PackagesModule.run(config, max_width)
  config = config or {}
  local counts = packages_util.get_info()
  
  local total_packages = 0
  local detailed_parts = {}
  
  local sorted_names = {}
  for name in pairs(counts) do
    table.insert(sorted_names, name)
  end
  table.sort(sorted_names)
  
  for _, name in ipairs(sorted_names) do
    local count = counts[name]
    total_packages = total_packages + count
    table.insert(detailed_parts, string.format("%d (%s)", count, name))
  end
  
  if total_packages == 0 then
    return
  end

  local icon = config.icon or "󰏖"
  local key = config.key or "Packages"
  local format = config.format or "{all} ({detailed})"
  
  local detailed_string = table.concat(detailed_parts, ", ")
  local value = format:gsub("{all}", tostring(total_packages))
                      :gsub("{detailed}", detailed_string)

  print(formatter.format(icon, key, value, config, max_width))
end

return PackagesModule
