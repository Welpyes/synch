local TOML = {}

function TOML.parse(content)
  local data = {}
  local current_section = data

  for line in content:gmatch("[^\r\n]+") do
    -- Trim whitespace
    line = line:gsub("^%s*(.-)%s*$", "%1")

    -- Ignore comments and empty lines
    if line ~= "" and not line:match("^#") then
      -- Section: [name]
      local section = line:match("^%[(.+)%]$")
      if section then
        data[section] = data[section] or {}
        current_section = data[section]
      else
        -- Key/Value: key = value
        local key, value = line:match("^([^=]+)%s*=%s*(.-)$")
        if key then
          key = key:gsub("%s+$", "")
          -- Strip comments from value
          value = value:match("^([^#]*)"):gsub("%s+$", "")

          -- Parse types
          if value:match("^%[.*%]$") then
            -- Array: ["a", "b"]
            local arr = {}
            for item in value:gmatch('"([^"]+)"') do
              table.insert(arr, item)
            end
            current_section[key] = arr
          elseif value:match('^".*"$') then
            -- String
            current_section[key] = value:sub(2, -2)
          else
            -- Boolean/Number
            if value == "true" then current_section[key] = true
            elseif value == "false" then current_section[key] = false
            else current_section[key] = tonumber(value) or value end
          end
        end
      end
    end
  end

  return data
end

return TOML
