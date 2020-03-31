--[[

================================================================================

  ProjectNukeApplicarionEAC
    Application: Emergency Alert Controller

================================================================================

  Author: stuntguy3000

--]]
function Run()
  -- Draw base GUI
  
  ProjectNukeCoreGUIUtil.DrawBaseGUI("Emergency Alert Controller", nil)
  
  ProjectNukeCoreGUIUtil.AddButton("btnALERT", "ALERT", "Send ALERT", colours.white, colours.red, 2, 11, 23, 6, SendAlert)
  ProjectNukeCoreGUIUtil.AddButton("btnCLEAR", "CLEAR", "Send CLEAR", colours.white, colours.green, 27, 11, 23, 6, SendClear)
  
  ProjectNukeCoreGUIUtil.StartEventListener()
end

function SendAlert()
  ProjectNukeEmergencyService.SendState("ALERT")
  ProjectNukeCoreGUIUtil.DrawStatus("Sent alert.")
  ProjectNukeCoreGUIUtil.StartEventListener()
end

function SendClear()
  ProjectNukeEmergencyService.SendState("CLEAR")
  ProjectNukeCoreGUIUtil.DrawStatus("Sent clear.")
  ProjectNukeCoreGUIUtil.StartEventListener()
end