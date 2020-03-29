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

local CurrentEmergencyState = "NONE"

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
    CurrentEmergencyState = EmergencyServicePacket.new(EmergencyServicePacket:getId(), Data['data'])
  end
end

function RunAlertSequence()
  ProjectNukeCoreGUIUtil.DrawErrorMessage({[1] = "ALERT"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawErrorMessage({[2] = "ALERT"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawErrorMessage({[3] = "ALERT"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawErrorMessage({[4] = "ALERT"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawErrorMessage({[5] = "ALERT"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawErrorMessage({[6] = "ALERT"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawErrorMessage({[7] = "ALERT"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawErrorMessage({[8] = "ALERT"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawErrorMessage({[9] = "ALERT"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawErrorMessage({[10] = "ALERT"}, 0.1)
end

function RunClearSequence()
  ProjectNukeCoreGUIUtil.DrawSuccessMessage({[1] = "CLEAR"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawSuccessMessage({[2] = "CLEAR"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawSuccessMessage({[3] = "CLEAR"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawSuccessMessage({[4] = "CLEAR"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawSuccessMessage({[5] = "CLEAR"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawSuccessMessage({[6] = "CLEAR"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawSuccessMessage({[7] = "CLEAR"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawSuccessMessage({[8] = "CLEAR"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawSuccessMessage({[9] = "CLEAR"}, 0.1)
  ProjectNukeCoreGUIUtil.DrawSuccessMessage({[10] = "CLEAR"}, 0.1)  
end