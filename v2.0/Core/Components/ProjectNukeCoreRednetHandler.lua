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
REDNET_PROTOCOL_MESSAGE_PATTERN = "(%a+);(.+)"

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
  decryptedMessage = ProjectNukeCoreEncryptionUtil:decrypt(ProjectNukeCoreConfigurationHandler.LoadedConfiguration.getEncryptionKey(), message)
  
  if (decryptedMessage == nil) then
    return nil
  end
  
  -- Attempt to unserialize the message
  decodedObject = textutils.unserialize(decryptedMessage)
  
  if (decodedObject == nil) then
    return nil
  end
  
  -- Verification checks
  -- Does it look like a packet?
  metadatatable = getmetatable(decodedObject)
  if (metadatatable == nil or metadatatable ~= ProjectNukeCorePackets.GeneralCommunicationPacket) then
    return nil
  end
  
  -- Does it smell like a packet?
  if (decodedObject:getID() ~= 0 or decodedObject:getData() == nil) then
    return nil
  end
  
  -- Check the payload
  decodedData = textutils.unserialize(decodedObject:getData())
  
  -- Does it look like a packet?
  if (decodedData == nil) then
    return nil
  end
  
  -- Does it smell like a packet?
  metadatatable = getmetatable(decodedData)
  if (metadatatable == nil or metadatatable ~= ProjectNukeCoreObjects.Packet) then
    return nil
  end
  
  return decodedData
end

Initalize()