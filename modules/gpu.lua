local GPUModule = {}
local gpu_util = require("utils.get-gpu")
local formatter = require("utils.formatter")

function GPUModule.run(config, max_width)
  config = config or {}
  local gpus = gpu_util.get_info()

  local icon = config.icon or "󰢮"
  local key = config.key or "Gpu"
  local format = config.format or "{name}"
  
  -- 1. Specific GPU indexing via format: {gpu1}, {gpu2}, etc.
  if format:find("{gpu%d+}") then
    local value = format
    for idx_str in format:gmatch("{gpu(%d+)}") do
      local idx = tonumber(idx_str)
      local gpu = gpus[idx]
      if gpu then
        value = value:gsub("{gpu" .. idx_str .. "}", gpu.name)
      else
        value = value:gsub("{gpu" .. idx_str .. "}", "None")
      end
    end
    print(formatter.format(icon, key, value, config, max_width))
    return
  end

  -- 2. {all} placeholder: prints all GPUs on separate lines
  if format:find("{all}") then
    for i, gpu in ipairs(gpus) do
      local gpu_key = #gpus > 1 and (key .. i) or key
      local value = format:gsub("{all}", gpu.name)
      print(formatter.format(icon, gpu_key, value, config, max_width))
    end
    return
  end

  -- 3. Default behavior: iterate and use {name}/{type}
  local index = config.index
  if index then
    local gpu = gpus[tonumber(index) + 1]
    if gpu then
      local value = format:gsub("{name}", gpu.name):gsub("{type}", gpu.type)
      print(formatter.format(icon, key, value, config, max_width))
    end
  else
    for i, gpu in ipairs(gpus) do
      local gpu_key = #gpus > 1 and (key .. i) or key
      local value = format:gsub("{name}", gpu.name):gsub("{type}", gpu.type)
      print(formatter.format(icon, gpu_key, value, config, max_width))
    end
  end
end

return GPUModule
