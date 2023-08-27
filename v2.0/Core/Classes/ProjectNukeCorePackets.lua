--[[

================================================================================

  ProjectNukeCorePackets
    A global registry of all packets that can be sent and recieved

================================================================================

  Author: stuntguy3000

--]]

-- GeneralCommunicationPacket
GeneralCommunicationPacket = ProjectNukeCoreClasses.Packet.new(0, nil)

-- EmergencyStatePacket
--    This packet represents an emergency state update, to be sent and recieved by ProjectNukeEmergencyService
EmergencyStatePacket = ProjectNukeCoreClasses.Packet.new(1, nil)