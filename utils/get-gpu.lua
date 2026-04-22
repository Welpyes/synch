local ffi = require("ffi")
local cache = require("utils.cache")

ffi.cdef[[
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
]]

local GPUUtil = {}
local memoized_gpus = nil

local function fetch_gpus()
    local vk
    local success_load = pcall(function() vk = ffi.load("vulkan") end)
    if not success_load then return nil end

    local instance = ffi.new("VkInstance[1]")
    local ci = ffi.new("VkInstanceCreateInfo")
    ffi.fill(ci, ffi.sizeof("VkInstanceCreateInfo"))
    ci.sType = ffi.C.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO

    if vk.vkCreateInstance(ci, nil, instance) ~= 0 then return nil end

    local count = ffi.new("uint32_t[1]")
    vk.vkEnumeratePhysicalDevices(instance[0], count, nil)
    
    if count[0] == 0 then
        vk.vkDestroyInstance(instance[0], nil)
        return {}
    end

    local devs = ffi.new("VkPhysicalDevice[?]", count[0])
    vk.vkEnumeratePhysicalDevices(instance[0], count, devs)

    local gpus = {}
    local types = { [0]="OTHER", [1]="INTEGRATED_GPU", [2]="DISCRETE_GPU", [3]="VIRTUAL_GPU", [4]="CPU" }

    for i = 0, count[0] - 1 do
        local props = ffi.new("VkPhysicalDeviceProperties")
        vk.vkGetPhysicalDeviceProperties(devs[i], props)
        table.insert(gpus, {
            name = ffi.string(props.deviceName),
            type = types[tonumber(props.deviceType)] or "UNKNOWN"
        })
    end

    vk.vkDestroyInstance(instance[0], nil)
    return gpus
end

function GPUUtil.get_info()
    if memoized_gpus then return memoized_gpus end

    local cached = cache.get("gpu")
    if cached then
        local gpus = {}
        -- Cache stores as "gpu0_name", "gpu0_type", etc.
        local i = 0
        while cached["gpu" .. i .. "_name"] do
            table.insert(gpus, {
                name = cached["gpu" .. i .. "_name"],
                type = cached["gpu" .. i .. "_type"]
            })
            i = i + 1
        end
        if #gpus > 0 then
            memoized_gpus = gpus
            return gpus
        end
    end

    local gpus = fetch_gpus()
    if gpus then
        local cache_data = {}
        for i, gpu in ipairs(gpus) do
            cache_data["gpu" .. (i-1) .. "_name"] = gpu.name
            cache_data["gpu" .. (i-1) .. "_type"] = gpu.type
        end
        cache.set("gpu", cache_data)
        memoized_gpus = gpus
    end

    return memoized_gpus or {}
end

return GPUUtil
