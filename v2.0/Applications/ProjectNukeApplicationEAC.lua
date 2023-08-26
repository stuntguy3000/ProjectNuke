--[[

================================================================================

  ProjectNukeApplicarionEAC
    Application: Emergency Alert Controller

================================================================================

  Author: stuntguy3000

--]]
function Run()
  -- Draw base GUI
  ProjectNukeCoreGUIUtil.DrawBaseGUI("Emergency Alert Controller v0.1", "Use this interface to send emergency alerts.")
  
  ProjectNukeCoreGUIUtil.AddButton("btnALERT", "ALERT", "Send ALERT", colours.white, colours.red, 2, 11, 23, 6, SendAlert)
  ProjectNukeCoreGUIUtil.AddButton("btnALLCLEAR", "ALLCLEAR", "Send ALL CLEAR", colours.white, colours.green, 27, 11, 23, 6, SendClear)
  
  ProjectNukeCoreGUIUtil.DrawStatus("Ready to send a message.")

  ProjectNukeCoreGUIUtil.StartEventListener()
end

function SendAlert()
  ProjectNukeEmergencyService.SendState("ALERT")

  ProjectNukeCoreGUIUtil.DrawStatus("ALERT message sent.")
  ProjectNukeCoreGUIUtil.StartEventListener()
end

function SendClear()
  ProjectNukeEmergencyService.SendState("ALLCLEAR")

  ProjectNukeCoreGUIUtil.DrawStatus("ALL CLEAR message sent.")
  ProjectNukeCoreGUIUtil.StartEventListener()
end