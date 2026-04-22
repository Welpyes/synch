local LogoGen = {}

local SM_SMUSH = 128
local SM_KERN  = 64

-- Parse FIGlet font header and return metadata table
local function parse_header(raw)
  local sig, hardblank, height, baseline, maxlen, old_layout, comment_lines =
    raw:match("^(flf2a)(.)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
  return {
    sig           = sig,
    hardblank     = hardblank,
    height        = tonumber(height),
    old_layout    = tonumber(old_layout),
    comment_lines = tonumber(comment_lines),
  }
end

local function resolve_smush_mode(old_layout)
  if old_layout ==  0 then return SM_KERN end
  if old_layout == -1 then return 0 end
  return (old_layout % 64) + SM_SMUSH
end

local function parse_char(file, height)
  local lines = {}
  for _ = 1, height do
    local line = file:read("*l")
    if not line then return nil end
    table.insert(lines, (line:gsub("@+$", "")))
  end
  return lines
end

function LogoGen.load_font(path)
  local file = io.open(path, "r")
  if not file then error("Could not open " .. path) end

  local header = parse_header(file:read("*l"))

  for _ = 1, header.comment_lines do file:read("*l") end

  local chars = {}
  for code = 32, 126 do
    chars[code] = parse_char(file, header.height)
  end
  file:close()

  return header, chars
end

local UNDERSCORE_SMUSHABLE = "|/\\%[%]{}%(%)<>"

local HIERARCHY = {
  ["|"]=1, ["/"]=2, ["\\"]=2,
  ["["]=3, ["]"]=3, ["{"]=4, ["}"]=4,
  ["("]=5, [")"]=5, ["<"]=6, [">"]=6,
}

local OPPOSITE_PAIRS = {
  ["[]"]=true, ["]["]=true,
  ["{}"]=true, ["}{"]=true,
  ["()"]=true, [")("]=true,
}

local function smush(leftChar, rightChar, hardblank, smushMode)
  if leftChar  == " " then return rightChar end
  if rightChar == " " then return leftChar  end

  if bit.band(smushMode, SM_SMUSH) == 0 then return nil end

  -- Rule 1: Equal character
  if bit.band(smushMode, 1) ~= 0
  and leftChar == rightChar
  and leftChar ~= hardblank then
    return leftChar
  end

  -- Rule 2: Underscore
  if bit.band(smushMode, 2) ~= 0 then
    if leftChar  == "_" and UNDERSCORE_SMUSHABLE:find(rightChar, 1, true) then return rightChar end
    if rightChar == "_" and UNDERSCORE_SMUSHABLE:find(leftChar,  1, true) then return leftChar  end
  end

  -- Rule 3: Hierarchy
  if bit.band(smushMode, 4) ~= 0 then
    local leftRank, rightRank = HIERARCHY[leftChar], HIERARCHY[rightChar]
    if leftRank and rightRank and leftRank ~= rightRank then
      return leftRank > rightRank and leftChar or rightChar
    end
  end

  -- Rule 4: Opposite pair
  if bit.band(smushMode, 8) ~= 0 and OPPOSITE_PAIRS[leftChar .. rightChar] then
    return "|"
  end

  -- Rule 5: Big X
  if bit.band(smushMode, 16) ~= 0 then
    if leftChar == "/"  and rightChar == "\\" then return "|" end
    if leftChar == "\\" and rightChar == "/"  then return "Y" end
    if leftChar == ">"  and rightChar == "<"  then return "X" end
  end

  -- Rule 6: Hardblank
  if bit.band(smushMode, 32) ~= 0
  and leftChar == hardblank
  and rightChar == hardblank then
    return hardblank
  end

  return nil
end

local function last_nonspace_index(line)
  if not line:find("[^ ]") then return 0 end
  local reversed = line:reverse()
  return line:len() - (reversed:find("[^ ]") or line:len()) + 1
end

local function first_nonspace_index(line)
  return line:find("[^ ]") or (line:len() + 1)
end

local function calc_smush_amount(outputLines, charLines, height, hardblank, smushMode)
  local amount = 1000000
  for row = 1, height do
    local outputLine = outputLines[row]
    local charLine   = charLines[row]

    local outputLastIdx = last_nonspace_index(outputLine)
    local charFirstIdx  = first_nonspace_index(charLine)

    local rowAmount = (charFirstIdx - 1) + (outputLine:len() - outputLastIdx)

    if outputLastIdx > 0 and charFirstIdx <= charLine:len() then
      local leftChar  = outputLine:sub(outputLastIdx, outputLastIdx)
      local rightChar = charLine:sub(charFirstIdx, charFirstIdx)
      if smush(leftChar, rightChar, hardblank, smushMode) then
          rowAmount = rowAmount + 1
      end
    end

    if rowAmount < amount then amount = rowAmount end
  end
  return amount
end

local function apply_smush(outputLines, charLines, height, smushAmount, hardblank, smushMode)
  local result = {}
  for row = 1, height do
    local outputLine = outputLines[row]
    local charLine   = charLines[row]

    local overlapStart = outputLine:len() - smushAmount + 1
    local newLine      = outputLine:sub(1, math.max(0, overlapStart - 1))

    for k = 1, smushAmount do
      local leftChar  = outputLine:sub(overlapStart + k - 1, overlapStart + k - 1)
      local rightChar = charLine:sub(k, k)
      if leftChar  == "" then leftChar  = " " end
      if rightChar == "" then rightChar = " " end
      newLine = newLine .. (smush(leftChar, rightChar, hardblank, smushMode) or " ")
    end

    result[row] = newLine .. charLine:sub(smushAmount + 1)
  end
  return result
end

function LogoGen.render(text, chars, height, hardblank, smushMode)
  local outputLines = {}
  for i = 1, height do outputLines[i] = "" end

  for charIndex = 1, #text do
    local charLines = chars[text:byte(charIndex)]
    if not charLines then goto continue end

    local smushAmount = calc_smush_amount(outputLines, charLines, height, hardblank, smushMode)
    if charIndex == 1 then smushAmount = 0 end

    outputLines = apply_smush(outputLines, charLines, height, smushAmount, hardblank, smushMode)

    ::continue::
  end

  return outputLines
end

function LogoGen.trim_trailing_blank_rows(outputLines, height, hardblank)
  local escapedHardblank = hardblank:gsub("[%%.%+%-%*%?%^%$%(%)%[]", "%%%1")
  local lastRow = height
  for row = height, 1, -1 do
    local cleaned = outputLines[row]:gsub(escapedHardblank, " ")
    if cleaned:find("[^ ]") then
      lastRow = row
      break
    end
  end
  return lastRow, escapedHardblank
end

function LogoGen.generate(text, font_file)
  local header, chars = LogoGen.load_font(font_file)
  local smushMode = resolve_smush_mode(header.old_layout)
  local outputLines = LogoGen.render(text, chars, header.height, header.hardblank, smushMode)

  local lastRow, escapedHardblank = LogoGen.trim_trailing_blank_rows(outputLines, header.height, header.hardblank)
  local result = {}
  for row = 1, lastRow do
    table.insert(result, (outputLines[row]:gsub(escapedHardblank, " ")))
  end
  return result
end

return LogoGen
