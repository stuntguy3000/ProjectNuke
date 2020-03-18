--[[

================================================================================

  ProjectNukeCoreRednetHandler
    Provides utilities for receiving and sending of communication messages using Rednet
    
  Messages recieved on the REDNET_PROTOCOL_ID channel are encrypted, and contain serialized PACKET data.
    
  Applications can request to recieve any MESSAGES addressed to them.

================================================================================

  Author: stuntguy3000

--]]

REDNET_PROTOCOL_ID = "ProjectNuke"

function Initalize()
  rednet.close()
  
    if (peripheral.getType("back") ~= "modem") then
      ProjectNukeCoreGUIUtil.DrawBaseGUI("Project Nuke", "Critical error occurred during startup")
  
      -- Labels
      window = ProjectNukeCoreGUIUtil.ProjectNukeGUI
      
      window.setTextColour(colours.white)
      window.setBackgroundColor(colours.lightGrey)
      window.setCursorPos(2,11) 
      window.write("Critical Error:")
      window.setTextColour(colours.grey)
      window.setBackgroundColor(colours.lightGrey)
      window.setCursorPos(2,13) 
      window.write("No modem detected on the back of this computer.")
      window.setCursorPos(2,15) 
      window.write("Please add one and click Reboot.")
    
      ProjectNukeCoreGUIUtil.AddButton("Reboot", nil, "Reboot", colours.white, colours.red, 41, 17, 10, 1, ProjectNukeCoreGUIUtil.ButtonShellCommandHandler("reboot"))
      ProjectNukeCoreGUIUtil.StartEventListener()
  end
  
  rednet.open("back")
end

function WaitForPacket(PacketID)
  senderId, message, protocol = rednet.receive(REDNET_PROTOCOL_ID)
  
  -- Attempt to decrypt the message
  decryptedMessage = ProjectNukeCoreEncryptionUtil.decrypt(ProjectNukeCoreConfigurationHandler.LoadedConfiguration:getEncryptionKey(), message)
  
  if (decryptedMessage == nil) then
    term.write("R E1")
    return nil
  end
  
  -- Attempt to unserialize the message
  decodedObject = ProjectNukeCoreFileUtil.Unserialize(decryptedMessage)
  
  
  --print(decryptedMessage)
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
  
  term.write("R 4")
  
  return decodedData
end

function SendPacket(Packet)
  -- Validation checks
  if (Packet == nil) then
    term.write("S E1")
    return false
  end
  
  metadatatable = getmetatable(Packet)
  if (metadatatable == nil or metadatatable ~= ProjectNukeCoreObjects.Packet) then
    term.write("S E2")
    return false
  end
  
  -- Encode the data
  encodedData = ProjectNukeCoreFileUtil.Serialize(Packet)
  
  if (encodedData == nil) then
    term.write("S E3")
    return false
  end
  
  -- Encapsulate it
  communicationPacket = ProjectNukeCorePackets.GeneralCommunicationPacket
  communicationPacket:setData(encodedData)
  
  -- Encrypt it
  communicationString = ProjectNukeCoreFileUtil.Serialize(communicationPacket)
  encryptedCommunicationString = ProjectNukeCoreEncryptionUtil.encrypt(ProjectNukeCoreConfigurationHandler.LoadedConfiguration:getEncryptionKey(), communicationString)
  
  -- Send it
  result = rednet.broadcast(encryptedCommunicationString, REDNET_PROTOCOL_ID)
  
  return result
end

Initalize()