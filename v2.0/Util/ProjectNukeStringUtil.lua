--[[

================================================================================

  ProjectNukeStringUtil
    Provides common String manipulation utilities

================================================================================

  Author: stuntguy3000

--]]

function string.split(input, maxLength)
  local lines = {}
   
  -- Split every maxLength characters
  while (string.len(input) >= maxLength) do
      -- Split & Add
      splitString = string.sub(input, 1, maxLength)
      table.insert(lines, splitString)

      -- Substring Remainder
      input = string.sub(input, maxLength, string.len(input))
  end

  -- Add the remainder
  if (input ~= nil and input ~= "") then
      table.insert(lines, input)
  end

  return lines
end

-- Author: http://lua-users.org/wiki/StringTrim
function string.trim(s)
  if (s == nil) then
    return nil
  end

  return s:match "^%s*(.-)%s*$"
end

-- Author: https://stackoverflow.com/a/22831842
function string.starts(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end