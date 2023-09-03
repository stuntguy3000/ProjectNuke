--[[

================================================================================

  ProjectNukeApplicarionEAC
    Application: Emergency Alert Controller

================================================================================

  Author: stuntguy3000

--]]
function getDisplayName()
  return "Emergency Alert Controller"
end

function run()
  -- Draw base GUI
  ProjectNukeCoreGUIHandler.DrawBaseGUI(getDisplayName(), "Use this interface to send emergency alerts.")

  window = ProjectNukeCoreGUIHandler.getMainWindow()

  -- Buttons
  window.setCursorPos(3, 11)
  window.setTextColor(colours.grey)
  window.setBackgroundColor(colours.lightGrey)
  window.write("Status Alerts:")

  ProjectNukeCoreGUIHandler.AddButton("btnALERT", "ALRT", "Send ALRT", colours.white, colours.orange, 3, 12, 11, 3, sendAlert, window)

  ProjectNukeCoreGUIHandler.AddButton("btnEVAC", "EVAC", "Send EVAC", colours.white, colours.red, 15, 12, 11, 3, sendEvac, window)
  ProjectNukeCoreGUIHandler.AddButton("btnOKAY", "OKAY", "Send OKAY", colours.white, colours.green, 27, 12, 11, 3, sendOkay, window)
  ProjectNukeCoreGUIHandler.AddButton("btnTEST", "TEST", "Send TEST", colours.white, colours.blue, 39, 12, 11, 3, sendTest, window)

  ProjectNukeCoreGUIHandler.AddButton("btnSENDCUSTOM", nil, "Send", colours.white, colours.purple, 44, 17, 6, 1, sendCustomMessage, window)
  
  -- Message
  window.setCursorPos(3, 16)
  window.setTextColor(colours.grey)
  window.setBackgroundColor(colours.lightGrey)

  window.write("Custom Message:")
  ProjectNukeCoreGUIHandler.FocusTextbox(ProjectNukeCoreGUIHandler.AddTextbox("EmergencyMessageInput", 3, 17, 40, window))

  -- Status
  ProjectNukeCoreGUIHandler.WriteStatus("Ready to send an alert.")

  -- Reset Cursor
  window.setCursorBlink(true)
  window.setCursorPos(3, 17)

  ProjectNukeCoreGUIHandler.StartEventListener()
end

function sleepGUI()
  window.setCursorBlink(false)

  ProjectNukeCoreGUIHandler.AddButton("btnALERT", "ALRT", "Send ALRT", colours.white, colours.grey, 3, 12, 11, 3, nil, window)
  ProjectNukeCoreGUIHandler.AddButton("btnEVAC", "EVAC", "Send EVAC", colours.white, colours.grey, 15, 12, 11, 3, nil, window)
  ProjectNukeCoreGUIHandler.AddButton("btnOKAY", "OKAY", "Send OKAY", colours.white, colours.grey, 27, 12, 11, 3, nil, window)
  ProjectNukeCoreGUIHandler.AddButton("btnTEST", "TEST", "Send TEST", colours.white, colours.grey, 39, 12, 11, 3, nil, window)
  ProjectNukeCoreGUIHandler.AddButton("btnSENDCUSTOM", nil, "Send", colours.white, colours.grey, 44, 17, 6, 1, nil, window)

  sleep(2)

  run()
end

function sendAlert()
  ProjectNukeServiceEMRG.sendState("STATUS", "ALRT")
  ProjectNukeCoreGUIHandler.WriteStatus("ALRT message sent.")

  sleepGUI()
end

function sendEvac()
  ProjectNukeServiceEMRG.sendState("STATUS", "EVAC")
  ProjectNukeCoreGUIHandler.WriteStatus("EVAC message sent.")

  sleepGUI()
end

function sendOkay()
  ProjectNukeServiceEMRG.sendState("STATUS", "OKAY")
  ProjectNukeCoreGUIHandler.WriteStatus("OKAY message sent.")

  sleepGUI()
end

function sendTest()
  ProjectNukeServiceEMRG.sendState("STATUS", "TEST")
  ProjectNukeCoreGUIHandler.WriteStatus("TEST message sent.")

  sleepGUI()
end

function sendCustomMessage()
  customMessageTextbox = ProjectNukeCoreGUIHandler.GetClickableItemByID("EmergencyMessageInput");
  customMessage = string.trim(customMessageTextbox:getValue())

  if (customMessage == nil or customMessage == "") then
    ProjectNukeCoreGUIHandler.DrawPopupMessage({"Error: Please enter a valid message."}, colors.red, 3)
    run()
    return
  end

  ProjectNukeServiceEMRG.sendState("MSG", customMessage)
  ProjectNukeCoreGUIHandler.WriteStatus("Custom message sent.")

  sleepGUI()
end