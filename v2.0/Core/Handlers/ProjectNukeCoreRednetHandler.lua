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
    term.write("R E1")
    return nil
  end
  
  -- Attempt to unserialize the message
  decodedObject = ProjectNukeCoreFileUtil.Unserialize(decryptedMessage)
  
  print(decryptedMessage)
  --print(decodedObject["id"])
  --print(decodedObject["data"])
  
  -- Does it smell like a packet?
  if (decodedObject == nil or decodedObject["id"] == nil or decodedObject["id"] ~= 0 or decodedObject["data"] == nil) then
    term.write("R E2")
    return nil
  end
  
  -- Check the payload
  decodedData = ProjectNukeCoreFileUtil.Unserialize(decodedObject["data"])
  
  if (decodedData == nil or decodedData["id"] == nil or decodedData["id"] ~= PacketID) then
    term.write("R E3")
    return nil
  end
  
  return decodedData
end

function BroadcastPacket(Packet)
  -- Validation checks
  if (Packet == nil) then
    term.write("S E1")
    return false
  end
  
  metadatatable = getmetatable(Packet)
  if (metadatatable == nil or metadatatable ~= ProjectNukeCoreClasses.Packet) then
    term.write("S E2")
    return false
  end
  
  -- Encode the data
  encodedData = ProjectNukeCoreFileUtil.Serialize(Packet)
  
  if (encodedData == nil) then
    term.write("S E3")
    return false
  end
  
  -- Encapsulate it (why?)
  communicationPacket = ProjectNukeCorePackets.GeneralCommunicationPacket
  communicationPacket:setData(encodedData)
  
  -- Encrypt it
  communicationString = ProjectNukeCoreFileUtil.Serialize(communicationPacket)
  encryptedCommunicationString = ProjectNukeCoreEncryptionUtil.encrypt(ProjectNukeCoreConfigurationHandler.LoadedConfiguration.encryptionKey, communicationString)
  
  -- Send it
  result = rednet.broadcast(encryptedCommunicationString, REDNET_PROTOCOL_ID)
  
  return result
end

Initalize()