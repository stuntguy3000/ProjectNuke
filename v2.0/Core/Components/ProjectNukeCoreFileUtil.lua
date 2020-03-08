--[[

================================================================================

  ProjectNukeCore-FileUtil
    Provides common file utilities & table encoding/decoding

================================================================================

  Author: stuntguy3000

--]]

function SaveTable(table, fileName)
  local file = fs.open(fileName, "w")
  file.write(textutils.serialize(table))
  file.close()
end

function LoadTable(fileName)
  local file = fs.open(fileName, "r")
  local data = file.readAll()
  file.close()
  return textutils.unserialize(data)
end