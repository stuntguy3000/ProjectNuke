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

REDNET_PROTOCOL_ID = "ProjectNuke"

-- Initalize REDNET Communications
function init()
  rednet.close()

  -- Try to locate a modem
  peripheral.find("modem", rednet.open)

  if (not rednet.isOpen()) then
    ProjectNukeCoreGUIUtil.DrawCriticalError({[8] = "No wireless modem detected.", [12] = "Please install one and click Reboot."})
  end
end

function WaitForPacket(PacketID)
  senderId, message, protocol = rednet.receive(REDNET_PROTOCOL_ID)

  -- Attempt to decrypt the message
  decryptedMessage = ProjectNukeCoreEncryptionUtil.decrypt(ProjectNukeCoreConfigurationHandler.getConfig().encryptionKey, message)

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
  encryptedPacket = ProjectNukeCoreEncryptionUtil.encrypt(ProjectNukeCoreConfigurationHandler.getConfig().encryptionKey, encodedPacket)

  -- Broadcast!
  return rednet.broadcast(encryptedPacket, REDNET_PROTOCOL_ID)
end

init()