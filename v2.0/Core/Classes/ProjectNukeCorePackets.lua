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
--      Array([1] => username, [2] => password, [3] => Application Name)
--      
AuthenticationRequestPacket = ProjectNukeCoreClasses.Packet.new(2, nil)

-- AuthenticationResponsePacket
--
--    Data Stucture
--      Boolean, True = Authentication Valid.
--      
AuthenticationResponsePacket = ProjectNukeCoreClasses.Packet.new(3, nil)