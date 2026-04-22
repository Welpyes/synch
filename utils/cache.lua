local Cache = {}

local cache_path = os.getenv("HOME") .. "/.cache/synch-cache.json"
local loaded_data = nil

local function read_file(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return content
end

local function write_file(path, content)
  local dir = path:match("(.*[/\\])")
  if dir then os.execute("mkdir -p " .. dir) end
  local file = io.open(path, "w")
  if not file then return end
  file:write(content)
  file:close()
end

local function parse_json(content)
  if not content then return nil end
  local data = {}
  local current_section = nil
  for line in content:gmatch("[^\r\n]+") do
    local section = line:match('^%s*"([^"]+)":%s*{%s*$')
    if section then
      if section ~= "cache" then
        data[section] = {}
        current_section = data[section]
      end
    else
      local k, v = line:match('^%s*"([^"]+)":%s*"([^"]+)"')
      if k and current_section then
        current_section[k] = v
      end
    end
  end
  return next(data) and data or nil
end

local function serialize_json(data)
  local lines = { '{', '  "cache": {' }
  local sections = {}
  for section_name, section_data in pairs(data) do
    local s_lines = { string.format('    "%s": {', section_name) }
    local items = {}
    for k, v in pairs(section_data) do
      table.insert(items, string.format('      "%s": "%s"', k, v))
    end
    table.insert(s_lines, table.concat(items, ",\n"))
    table.insert(s_lines, '    }')
    table.insert(sections, table.concat(s_lines, "\n"))
  end
  table.insert(lines, table.concat(sections, ",\n"))
  table.insert(lines, '  }')
  table.insert(lines, '}')
  return table.concat(lines, "\n")
end

function Cache.get(section)
  if not loaded_data then
    loaded_data = parse_json(read_file(cache_path)) or {}
  end
  return loaded_data[section]
end

function Cache.set(section, info)
  if not loaded_data then
    loaded_data = parse_json(read_file(cache_path)) or {}
  end
  loaded_data[section] = info
  write_file(cache_path, serialize_json(loaded_data))
end

return Cache
