--[[

================================================================================

  ProjectNukeServiceEMRG
    Provides a listener and action response to an emergency alarms and incidents.
    
    Three emergency states:
      ALERT
      CLEAR
      NONE

================================================================================

  Author: stuntguy3000

--]]

local emergencyStatePacket = ProjectNukeCorePackets.EmergencyStatePacket

local emergencyState = "NONE"

function sendState(newEmergencyState)
  emergencyStatePacket:setData(newEmergencyState)
  ProjectNukeCoreRednetHandler.BroadcastPacket(emergencyStatePacket)
end

function runAlertSequence()
  for i = 3,1,-1 do
    ProjectNukeCoreGUIUtil.DrawErrorMessages({[1] = "ALERT"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawErrorMessages({[2] = "ALERT"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawErrorMessages({[3] = "ALERT"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawErrorMessages({[4] = "ALERT"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawErrorMessages({[5] = "ALERT"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawErrorMessages({[6] = "ALERT"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawErrorMessages({[7] = "ALERT"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawErrorMessages({[8] = "ALERT"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawErrorMessages({[9] = "ALERT"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawErrorMessages({[10] = "ALERT"}, 0.1)
  end
  
  emergencyState = "NONE"
end

function runAllClearSequence()
  for i = 3,1,-1 do
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[1] = "ALL CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[2] = "ALL CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[3] = "ALL CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[4] = "ALL CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[5] = "ALL CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[6] = "ALL CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[7] = "ALL CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[8] = "ALL CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[9] = "ALL CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[10] = "ALL CLEAR"}, 0.1)
  end
  
  emergencyState = "NONE"
end

-- Standard Functions
function run()
  if (emergencyState == "ALERT") then
    runAlertSequence()

  elseif (emergencyState == "ALLCLEAR") then
    runAllClearSequence()
  else
    -- Wait for receipt of emergency service packet
    packetData = ProjectNukeCoreRednetHandler.WaitForPacket(emergencyStatePacket:getId())

    if (packetData ~= nil) then
      emergencyState = emergencyStatePacket.new(emergencyStatePacket:getId(), packetData['data']):getData()
    end
  end

  run()
end

function getDisplayName()
  return "Emergency Alert Service"
end