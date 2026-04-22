local GPUModule = {}
local gpu_util = require("utils.get-gpu")
local formatter = require("utils.formatter")

function GPUModule.run(config, max_width)
  config = config or {}
  local gpus = gpu_util.get_info()

  local icon = config.icon or "󰢮"
  local key = config.key or "Gpu"
  local format = config.format or "{name} | {type}"
  local index = config.index -- optional: nil means all, 0-N means specific

  local function print_gpu(gpu, gpu_key)
    local value = format:gsub("{name}", gpu.name)
                        :gsub("{type}", gpu.type)
    print(formatter.format(icon, gpu_key or key, value, config, max_width))
  end

  if index then
    local gpu = gpus[tonumber(index) + 1]
    if gpu then print_gpu(gpu) end
  else
    for i, gpu in ipairs(gpus) do
      local gpu_key = #gpus > 1 and (key .. i) or key
      print_gpu(gpu, gpu_key)
    end
  end
end

return GPUModule
