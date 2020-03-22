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

function SendState(EmergencyState)
  EmergencyServicePacket:setData(EmergencyState)
  ProjectNukeCoreRednetHandler.SendPacket(EmergencyServicePacket)
end

function Run()
  -- Wait for receipt of emergency service packet
  Data = ProjectNukeCoreRednetHandler.WaitForPacket(EmergencyServicePacket:getId())
  EmergencyState = EmergencyServicePacket.new(EmergencyServicePacket:getId(), Data['data'])
  
  if (EmergencyState == "ALERT") then
    RunAlertSequence()
  elseif (EmergencyState == "CLEAR") then
    RunClearSequence()
  else
    Run()
  end
end

function RunAlertSequence()
  -- Trigger a redstone
end

function RunClearSequence()
  
end