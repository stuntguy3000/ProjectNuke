--[[

================================================================================

  ProjectNukeApplicarionRNET
    Application: REDNET Monitor

    This application allows the monitoring of REDNET Communications.

================================================================================

  Author: stuntguy3000

--]]
function run()
  ProjectNukeCoreGUIUtil.initGui(true)
  ProjectNukeCoreGUIUtil.DrawBaseGUI(getDisplayName(), nil)

  -- Draw GUI Elements
  window = ProjectNukeCoreGUIUtil.MainWindow
  windowSize = {window.getSize()}

  ProjectNukeCoreGUIUtil.DrawFilledBoxInWindow(colors.gray, 2, 9, windowSize[1] - 1, 18, window)

  -- Draw Labels
  window.setCursorPos(2, 8)
  window.setBackgroundColour(colors.lightGray)
  window.setTextColour(colors.gray)
  window.write("Last Recieved Message:")

  -- Await Message
  while true do
    printMessage(awaitMessage())
  end
end

function printMessage(message)
  -- Reset
  ProjectNukeCoreGUIUtil.DrawFilledBoxInWindow(colors.gray, 2, 9, windowSize[1] - 1, 18, window)
  window.setBackgroundColour(colors.gray)
  window.setTextColour(colors.black)

  -- Sanitize Message
  message = string.gsub(message, "n", "")

  -- Print
  window.setCursorPos(2, 3)
  print(message)
end

function awaitMessage()
  -- Custom Copypasta from REDNET Handler
  senderId, message, protocol = rednet.receive(ProjectNukeCoreRednetHandler.REDNET_PROTOCOL_ID) 

  -- Attempt to decrypt the message
  decryptedMessage = ProjectNukeCoreEncryptionUtil.decrypt(ProjectNukeCoreConfigurationHandler.LoadedConfiguration.encryptionKey, message)

  if (decryptedMessage ~= nil) then
    return decryptedMessage
  end

  -- On error, loop.
  awaitMessage()
end

function getDisplayName()
  return "REDNET Monitor"
end