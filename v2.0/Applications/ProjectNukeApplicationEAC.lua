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

  ProjectNukeCoreGUIHandler.AddButton("btnALERT", "ALRT", "Send ALRT", colours.white, colours.orange, 3, 12, 11, 3, sendAlert)
  ProjectNukeCoreGUIHandler.AddButton("btnEVAC", "EVAC", "Send EVAC", colours.white, colours.red, 15, 12, 11, 3, sendEvac)
  ProjectNukeCoreGUIHandler.AddButton("btnOKAY", "OKAY", "Send OKAY", colours.white, colours.green, 27, 12, 11, 3, sendOkay)
  ProjectNukeCoreGUIHandler.AddButton("btnTEST", "TEST", "Send TEST", colours.white, colours.blue, 39, 12, 11, 3, sendTest)

  ProjectNukeCoreGUIHandler.AddButton("btnSENDCUSTOM", nil, "Send", colours.white, colours.purple, 44, 17, 6, 1, sendCustomMessage)
  
  -- Message
  window.setCursorPos(3, 16)
  window.setTextColor(colours.grey)
  window.setBackgroundColor(colours.lightGrey)

  window.write("Custom Message:")
  ProjectNukeCoreGUIHandler.UpdateTextbox(ProjectNukeCoreGUIHandler.AddTextbox("EmergencyMessageInput", 3, 17, 40))

  -- Status
  ProjectNukeCoreGUIHandler.DrawStatus("Ready to send an alert.")

  -- Reset Cursor
  window.setCursorBlink(true)
  window.setCursorPos(3, 17)

  ProjectNukeCoreGUIHandler.StartEventListener()
end

function sleepGUI()
  window.setCursorBlink(false)

  ProjectNukeCoreGUIHandler.AddButton("btnALERT", "ALRT", "Send ALRT", colours.white, colours.grey, 3, 12, 11, 3, nil)
  ProjectNukeCoreGUIHandler.AddButton("btnEVAC", "EVAC", "Send EVAC", colours.white, colours.grey, 15, 12, 11, 3, nil)
  ProjectNukeCoreGUIHandler.AddButton("btnOKAY", "OKAY", "Send OKAY", colours.white, colours.grey, 27, 12, 11, 3, nil)
  ProjectNukeCoreGUIHandler.AddButton("btnTEST", "TEST", "Send TEST", colours.white, colours.grey, 39, 12, 11, 3, nil)
  ProjectNukeCoreGUIHandler.AddButton("btnSENDCUSTOM", nil, "Send", colours.white, colours.grey, 44, 17, 6, 1, nil)

  sleep(2)

  run()
end

function sendAlert()
  ProjectNukeServiceEMRG.sendState("STATUS_ALRT")
  ProjectNukeCoreGUIHandler.DrawStatus("ALRT message sent.")

  sleepGUI()
end

function sendEvac()
  ProjectNukeServiceEMRG.sendState("STATUS_EVAC")
  ProjectNukeCoreGUIHandler.DrawStatus("EVAC message sent.")

  sleepGUI()
end

function sendOkay()
  ProjectNukeServiceEMRG.sendState("STATUS_OKAY")
  ProjectNukeCoreGUIHandler.DrawStatus("OKAY message sent.")

  sleepGUI()
end

function sendTest()
  ProjectNukeServiceEMRG.sendState("STATUS_TEST")
  ProjectNukeCoreGUIHandler.DrawStatus("TEST message sent.")

  sleepGUI()
end

function sendCustomMessage()
  customMessageTextbox = ProjectNukeCoreGUIHandler.GetClickableItemByID("EmergencyMessageInput");
  customMessage = ProjectNukeCoreStringUtil.trim(customMessageTextbox:getValue())

  if (customMessage == nil or customMessage == "") then
    ProjectNukeCoreGUIHandler.drawPopupMessage({"Error: Please enter a valid message."}, colors.red, 3)
    run()
    return
  end

  ProjectNukeServiceEMRG.sendState("MSG_" .. customMessage)
  ProjectNukeCoreGUIHandler.DrawStatus("Custom message sent.")

  sleepGUI()
end