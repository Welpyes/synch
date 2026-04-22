local TOML = {}

function TOML.parse(content)
  local data = {}
  local current_section = data
  local in_array = false
  local array_key = nil
  local array_buffer = ""

  for line in content:gmatch("[^\r\n]+") do
    line = line:gsub("^%s*(.-)%s*$", "%1")

    if line ~= "" and not line:match("^#") then
      if in_array then
        array_buffer = array_buffer .. line
        if line:match("%]") then
          local arr = {}
          for item in array_buffer:gmatch('"([^"]+)"') do
            table.insert(arr, item)
          end
          current_section[array_key] = arr
          in_array = false
        end
      else
        local section = line:match("^%[(.+)%]$")
        if section then
          data[section] = data[section] or {}
          current_section = data[section]
        else
          local key, value = line:match("^([^=]+)%s*=%s*(.-)$")
          if key then
            key = key:gsub("%s+$", "")
            value = value:match("^([^#]*)"):gsub("%s+$", "")

            if value:match("^%[") and not value:match("%]$") then
              in_array = true
              array_key = key
              array_buffer = value
            elseif value:match("^%[.*%]$") then
              local arr = {}
              for item in value:gmatch('"([^"]+)"') do
                table.insert(arr, item)
              end
              current_section[key] = arr
            elseif value:match('^".*"$') then
              current_section[key] = value:sub(2, -2)
            else
              if value == "true" then current_section[key] = true
              elseif value == "false" then current_section[key] = false
              else current_section[key] = tonumber(value) or value end
            end
          end
        end
      end
    end
  end

  return data
end

return TOML
