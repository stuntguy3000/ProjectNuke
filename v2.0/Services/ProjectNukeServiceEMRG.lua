--[[

================================================================================

  ProjectNukeServiceEMRG
    Provides a listener and action response to an emergency messages.

================================================================================

  Author: stuntguy3000

--]]

function getDisplayName()
  return "Emergency Alert Service"
end

function sendState(newEmergencyState)
  local emergencyStatePacket = ProjectNukeCorePackets.EmergencyStatePacket

  emergencyStatePacket:setData(newEmergencyState)
  ProjectNukeCoreRednetHandler.BroadcastPacket(emergencyStatePacket)
end

function displayEmergencyMessage(message)
  ProjectNukeCoreGUIUtil.drawPopupMessage({message}, colours.purple, 10)
end

-- Standard Functions
function run()
  local emergencyStatePacket = ProjectNukeCorePackets.EmergencyStatePacket

  -- Await Incoming Emergency Packet
  packetData = ProjectNukeCoreRednetHandler.WaitForPacket(emergencyStatePacket:getId())

  if (packetData ~= nil) then
    incomingMessage = emergencyStatePacket.new(emergencyStatePacket:getId(), packetData['data']):getData()
  end

  if (incomingMessage ~= nil and incomingMessage ~= "") then
    if (string.find(incomingMessage, "STATUS_") ~= nil) then
      -- Process Status Update
      emergencyStatus = string.sub(incomingMessage, 8, string.len(incomingMessage))

      -- TODO
    elseif (string.find(incomingMessage, "MSG_") ~= nil) then
      -- Process Custom Message
      emergencyMessage = string.sub(incomingMessage, 5, string.len(incomingMessage))

      if (emergencyMessage ~= nil and displayEmergencyMessage ~= "") then
        -- Sanity check
        displayEmergencyMessage(emergencyMessage)
      end
    end
  end
  -- Rinse and repeat
  run()
end