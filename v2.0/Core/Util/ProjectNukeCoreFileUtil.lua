--[[

================================================================================

  ProjectNukeCoreFileUtil
    Provides common file utilities & table encoding/decoding

================================================================================

  Author: stuntguy3000

--]]

function SaveTable(table, fileName)
  local file = fs.open(fileName, "w")
  data = Serialize(table)
  
  file.write(data)
  file.close()
end

function LoadTable(fileName)
  local file = fs.open(fileName, "r")
  local data = file.readAll()
  file.close()
  return Unserialize(data)
end

function Serialize(data)
  return textutils.serialize(data)
end

function Unserialize(data)
  return textutils.unserialize(data)
end