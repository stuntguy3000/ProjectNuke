--[[

================================================================================

  ProjectNukeCoreRednetHandler
    Provides utilities for receiving and sending of communication messages using REDNET
    
    REDNET is used for all ProjectNuke communications. All communications are encrypted with a shared key using SHA256 encryption.
    All ProjectNuke computers must share the same key to particiate in the network.

    The protocol is clearly defined and broken down into packets with individual uses. See ProjectNukeCorePackets.

    All computers using REDNET subscribed to the ProjectNuke Protocol, including other power stations, will receieve these communications.
    HOWEVER, due to the encryption, they are not readable. ProjectNuke ignores all packets it cannot decrypt, even from other ProjectNuke installations.

    It is unclear if this is vulvernable to network flood attacks or other simliar network concerns. 
    In future we can evaluate a hardwire communication backhaul if required.

    However, for now - this will suit. It's fast, it's simple, and it works flawlessly.

================================================================================

  Author: stuntguy3000

--]]

REDNET_PROTOCOL_ID = "ProjectNuke_"

-- Initalize REDNET Communications
function init()
  rednet.close()

  -- Try to locate and open a modem
  peripheral.find("modem", rednet.open)

  if (not rednet.isOpen()) then
    ProjectNukeCoreGUIHandler.DrawPopupMessage({"No Ender modem detected.", "","", "Please install one and click Reboot."}, colours.red, -1)
  end

  -- Set Protocol ID
  REDNET_PROTOCOL_ID = REDNET_PROTOCOL_ID .. ProjectNukeCoreConfigurationHandler.getConfig().plantName
  print("Rednet Protocol ID is " .. REDNET_PROTOCOL_ID)
end

function WaitForPacket(ExpectedPacket, Timeout)
  local senderId = nil
  local message = nil
  local protocol = nil

  if (Timeout == nil) then
    senderId, message, protocol = rednet.receive(REDNET_PROTOCOL_ID)
  else
    senderId, message, protocol = rednet.receive(REDNET_PROTOCOL_ID, Timeout)
  end

  -- Nil Check
  if (senderId == nil or message == nil or protocol == nil) then
    return nil
  end

  -- Attempt to decrypt the message
  decryptedMessage = ProjectNukeEncryptionUtil.decrypt(ProjectNukeCoreConfigurationHandler.getConfig().encryptionKey, message)

  if (decryptedMessage == nil) then
    return nil
  end

  -- Attempt to unserialize the message
  decryptedMessageTable = ProjectNukeFileUtil.Unserialize(decryptedMessage)

  -- Does it smell like a packet?
  local expectedPacketID = ExpectedPacket:getID()
  if (decryptedMessageTable == nil or decryptedMessageTable["id"] == nil or decryptedMessageTable["data"] == nil or decryptedMessageTable["id"] ~= expectedPacketID) then
    return nil
  end

  -- Set ExpectedPacket's data
  ExpectedPacket:setData(decryptedMessageTable["data"])

  return ExpectedPacket
end

function SendPacket(Packet)
  -- Validation checks
  if (Packet == nil) then
    return false
  end

  metadatatable = getmetatable(Packet)
  if (metadatatable == nil or metadatatable ~= ProjectNukeCoreClasses.Packet) then
    return false
  end

  -- Encode the data
  encodedPacket = ProjectNukeFileUtil.Serialize(Packet)

  if (encodedPacket == nil) then
    return false
  end

  -- Encrypt the packet
  encryptedPacket = ProjectNukeEncryptionUtil.encrypt(ProjectNukeCoreConfigurationHandler.getConfig().encryptionKey, encodedPacket)

  -- Broadcast!
  return rednet.broadcast(encryptedPacket, REDNET_PROTOCOL_ID)
end

init()