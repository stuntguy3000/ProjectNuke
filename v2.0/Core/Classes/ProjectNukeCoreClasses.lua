--[[

================================================================================

  ProjectNukeCoreClasses
    A generic class containing all Lua class objects used by various components and applications

================================================================================

  Author: stuntguy3000

--]]

-- Config Object
Config = {}
Config.__index = Config

function Config.new(encryptionKey, enabledApplication, plantName, monitorSupport)
  local self = setmetatable({}, Config)

  self.encryptionKey = encryptionKey
  self.enabledApplication = enabledApplication
  self.plantName = plantName
  self.monitorSupport = monitorSupport

  return self
end
-- Config Object End

-- Packet Object
Packet = {}
Packet.__index = Packet

function Packet.new(id, data)
  local self = setmetatable({}, Packet)

  self.id = id
  self.data = data

  return self
end

function Packet.getID(self)
  return self.id
end

function Packet.getData(self)
  return self.data
end

function Packet.setData(self, data)
  self.data = data
end
-- Packet Object End