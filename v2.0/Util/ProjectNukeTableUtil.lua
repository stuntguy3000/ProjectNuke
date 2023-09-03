--[[

================================================================================

  ProjectNukeFileUtil
    Provides common file utilities & table encoding/decoding

================================================================================

  Author: stuntguy3000

--]]

-- https://gist.github.com/walterlua/978150/2742d9479cd5bfb3d08d90cfcb014da94021e271
function table.indexOf(t, object)
  if type(t) ~= "table" then error("table expected, got " .. type(t), 2) end

  for i, v in pairs(t) do
     if object == v then
        return i
     end
  end
end