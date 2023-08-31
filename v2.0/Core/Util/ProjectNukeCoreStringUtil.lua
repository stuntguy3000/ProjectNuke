--[[

================================================================================

  ProjectNukeCoreStringUtil
    Provides common String manipulation utilities

================================================================================

  Author: stuntguy3000

--]]

function split(input, maxLength)
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