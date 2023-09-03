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

function sendState(type, data)
  local emergencyStatePacket = ProjectNukeCorePackets.EmergencyStatePacket

  emergencyStatePacket:setData({type, data})
  ProjectNukeCoreRednetHandler.BroadcastPacket(emergencyStatePacket)
end

function displayEmergencyMessage(message)
  ProjectNukeCoreGUIHandler.DrawPopupMessage({message}, colours.purple, 10)
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
    type = incomingMessage[1]
    data = incomingMessage[2]

    if (type == "STATUS") then
      -- Process Status Update
      emergencyStatus = data

      -- TODO
      displayEmergencyMessage("Status: ".. type .."\nData: "..data)
    elseif (type == "MSG") then
      -- Process Custom Message
      if (data ~= nil) then
        -- Sanity check
        displayEmergencyMessage(data)
      end
    end
  end
  -- Rinse and repeat
  run()
end