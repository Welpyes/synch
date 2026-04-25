local ffi = require("ffi")
local cache = require("utils.cache")

pcall(ffi.cdef, [[
  typedef void* VkInstance;
  typedef void* VkPhysicalDevice;
  typedef uint32_t VkFlags;
  typedef enum VkStructureType {
    VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO = 1,
    VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES = 5
  } VkStructureType;

  typedef struct VkInstanceCreateInfo {
    VkStructureType sType;
    const void* pNext;
    VkFlags flags;
    const void* pApplicationInfo;
    uint32_t enabledLayerCount;
    const char* const* ppEnabledLayerNames;
    uint32_t enabledExtensionCount;
    const char* const* ppEnabledExtensionNames;
  } VkInstanceCreateInfo;

  typedef struct VkPhysicalDeviceProperties {
    uint32_t apiVersion;
    uint32_t driverVersion;
    uint32_t vendorID;
    uint32_t deviceID;
    int32_t deviceType;
    char deviceName[256];
    uint8_t pipelineCacheUUID[16];
    char data[1024]; 
  } VkPhysicalDeviceProperties;

  int vkCreateInstance(const VkInstanceCreateInfo* pCreateInfo, const void* pAllocator, VkInstance* pInstance);
  void vkDestroyInstance(VkInstance instance, const void* pAllocator);
  int vkEnumeratePhysicalDevices(VkInstance instance, uint32_t* pPhysicalDeviceCount, VkPhysicalDevice* pPhysicalDevices);
  void vkGetPhysicalDeviceProperties(VkPhysicalDevice physicalDevice, VkPhysicalDeviceProperties* pProperties);
]])

local GPU = {}
local memoized_gpu_list = nil

local function fetch_gpus_via_vulkan()
  local vulkan_library
  local success_loading = pcall(function() vulkan_library = ffi.load("vulkan") end)
  if not success_loading then return nil end

  local instance_handle = ffi.new("VkInstance[1]")
  local instance_create_info = ffi.new("VkInstanceCreateInfo")
  ffi.fill(instance_create_info, ffi.sizeof("VkInstanceCreateInfo"))
  instance_create_info.sType = ffi.C.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO

  if vulkan_library.vkCreateInstance(instance_create_info, nil, instance_handle) ~= 0 then 
    return nil 
  end

  local physical_device_count = ffi.new("uint32_t[1]")
  vulkan_library.vkEnumeratePhysicalDevices(instance_handle[0], physical_device_count, nil)
  
  if physical_device_count[0] == 0 then
    vulkan_library.vkDestroyInstance(instance_handle[0], nil)
    return {}
  end

  local physical_devices = ffi.new("VkPhysicalDevice[?]", physical_device_count[0])
  vulkan_library.vkEnumeratePhysicalDevices(instance_handle[0], physical_device_count, physical_devices)

  local gpu_list = {}
  local device_type_names = { 
    [0] = "OTHER", 
    [1] = "INTEGRATED_GPU", 
    [2] = "DISCRETE_GPU", 
    [3] = "VIRTUAL_GPU", 
    [4] = "CPU" 
  }

  for index = 0, physical_device_count[0] - 1 do
    local properties = ffi.new("VkPhysicalDeviceProperties")
    vulkan_library.vkGetPhysicalDeviceProperties(physical_devices[index], properties)
    table.insert(gpu_list, {
      name = ffi.string(properties.deviceName),
      type = device_type_names[tonumber(properties.deviceType)] or "UNKNOWN"
    })
  end

  vulkan_library.vkDestroyInstance(instance_handle[0], nil)
  return gpu_list
end

function GPU.get_info()
  if memoized_gpu_list then return memoized_gpu_list end

  local cached_data = cache.get("gpu")
  if cached_data then
    local gpu_list = {}
    local gpu_index = 0
    while cached_data["gpu" .. gpu_index .. "_name"] do
      table.insert(gpu_list, {
        name = cached_data["gpu" .. gpu_index .. "_name"],
        type = cached_data["gpu" .. gpu_index .. "_type"]
      })
      gpu_index = gpu_index + 1
    end
    if #gpu_list > 0 then
      memoized_gpu_list = gpu_list
      return memoized_gpu_list
    end
  end

  local gpu_list = fetch_gpus_via_vulkan()
  if gpu_list then
    local cache_payload = {}
    for index, gpu in ipairs(gpu_list) do
      cache_payload["gpu" .. (index - 1) .. "_name"] = gpu.name
      cache_payload["gpu" .. (index - 1) .. "_type"] = gpu.type
    end
    cache.set("gpu", cache_payload)
    memoized_gpu_list = gpu_list
  end

  return memoized_gpu_list or {}
end

return GPU
