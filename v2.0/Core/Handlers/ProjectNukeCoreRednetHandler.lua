--[[

================================================================================

  ProjectNukeCoreRednetHandler
    Provides utilities for receiving and sending of communication messages using Rednet
    
  Messages recieved on the REDNET_PROTOCOL_ID channel are encrypted, and contain serialized PACKET data.
    
  Applications can request to recieve any MESSAGES addressed to them.

  Packet Map:
    ID    USAGE
    0     REDNET Communication Wrapper
    1     REDNET Emergency Service Protocol

================================================================================

  Author: stuntguy3000

--]]

REDNET_PROTOCOL_ID = "ProjectNuke"

function Initalize()
  rednet.close()
  
  if (peripheral.getType("back") ~= "modem") then
    ProjectNukeCoreGUIUtil.DrawCriticalError({[8] = "No modem installed on back side.", [12] = "Please install one and click Reboot."})
  end
  
  rednet.open("back")
end

function WaitForPacket(PacketID)
  senderId, message, protocol = rednet.receive(REDNET_PROTOCOL_ID)
  
  -- Attempt to decrypt the message
  decryptedMessage = ProjectNukeCoreEncryptionUtil.decrypt(ProjectNukeCoreConfigurationHandler.LoadedConfiguration.encryptionKey, message)
  
  if (decryptedMessage == nil) then
    return nil
  end
  
  -- Attempt to unserialize the message
  decodedObject = ProjectNukeCoreFileUtil.Unserialize(decryptedMessage)
  
  -- Does it smell like a packet?
  if (decodedObject == nil or decodedObject["id"] == nil or decodedObject["id"] ~= PacketID) then
    return nil
  end
  
  return decodedObject
end

function BroadcastPacket(Packet)
  -- Validation checks
  if (Packet == nil) then
    return false
  end
  
  metadatatable = getmetatable(Packet)
  if (metadatatable == nil or metadatatable ~= ProjectNukeCoreClasses.Packet) then
    return false
  end
  
  -- Encode the data
  encodedPacket = ProjectNukeCoreFileUtil.Serialize(Packet)
  
  if (encodedPacket == nil) then
    return false
  end

  -- Encrypt the packet
  encryptedPacket = ProjectNukeCoreEncryptionUtil.encrypt(ProjectNukeCoreConfigurationHandler.LoadedConfiguration.encryptionKey, encodedPacket)
  
  -- Broadcast!
  return rednet.broadcast(encryptedPacket, REDNET_PROTOCOL_ID)
end

Initalize()