--[[

================================================================================

  ProjectNukeEmergencyService
    Provides a listener and action response to an emergency alarm.
    
    Three emergency states:
      ALERT
      CLEAR
      NONE

================================================================================

  Author: stuntguy3000

--]]

-- Service Packet Definitions
local EmergencyServicePacket = ProjectNukeCoreClasses.Packet.new(1, nil)
-- End Service Packet Definitions

local EmergencyState = "NONE"

function SendState(EmergencyState)
  EmergencyServicePacket:setData(EmergencyState)
  ProjectNukeCoreRednetHandler.SendPacket(EmergencyServicePacket)
end

function Run()
  if (EmergencyState == "ALERT") then
    RunAlertSequence()
  elseif (EmergencyState == "CLEAR") then
    RunClearSequence()
  else
    -- Wait for receipt of emergency service packet
    Data = ProjectNukeCoreRednetHandler.WaitForPacket(EmergencyServicePacket:getId())
    EmergencyState = EmergencyServicePacket.new(EmergencyServicePacket:getId(), Data['data']):getData()
  end
end

function RunAlertSequence()
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
end

function RunClearSequence()
  for i = 3,1,-1 do
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[1] = "CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[2] = "CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[3] = "CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[4] = "CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[5] = "CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[6] = "CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[7] = "CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[8] = "CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[9] = "CLEAR"}, 0.1)
    ProjectNukeCoreGUIUtil.DrawSuccessMessages({[10] = "CLEAR"}, 0.1)  
  end
end