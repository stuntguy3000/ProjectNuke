--[[

================================================================================

  ProjectNukeCorePackets
    A global registry of all packets that can be sent and recieved

================================================================================

  Author: stuntguy3000

--]]

-- EmergencyStatePacket
--    This packet represents an emergency state update, to be sent and recieved by ProjectNukeEmergencyService
--
--    Data Stucture
--      Array([1] => enum(STATUS_CHANGE or MESSAGE), [2] => Misc. Data)
--      
EmergencyStatePacket = ProjectNukeCoreClasses.Packet.new(1, nil)

-- AuthenticationRequestPacket
--
--    Data Stucture
--      Array([1] => username, [2] => password)
--      
AuthenticationRequestPacket = ProjectNukeCoreClasses.Packet.new(2, nil)

-- AuthenticationResponsePacket
--
--    Data Stucture
--      Array([1] => True (if authenticated), [3] => checksum [sha256 of username .. password])
--      
AuthenticationResponsePacket = ProjectNukeCoreClasses.Packet.new(3, nil)

-- InventoryRequestStatus
--
--    Data Stucture
--      [None]
--      
InventoryRequestStatus = ProjectNukeCoreClasses.Packet.new(4, nil)

-- InventoryResponseStatus
--
--    Data Stucture
--      Array([1] => ID of Enabled Application)
--      
InventoryResponseStatus = ProjectNukeCoreClasses.Packet.new(5, nil)