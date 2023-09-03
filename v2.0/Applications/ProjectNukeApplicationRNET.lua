--[[

================================================================================

  ProjectNukeApplicarionRNET
    Application: REDNET Monitor

    This application allows the monitoring of REDNET Communications.

================================================================================

  Author: stuntguy3000

--]]
local messageBuffer = {}

function run()
  ProjectNukeCoreGUIHandler.initGui(true)
  ProjectNukeCoreGUIHandler.DrawBaseGUI(getDisplayName(), nil)
  ProjectNukeCoreGUIHandler.DrawStatus("Listening for messages...")

  -- Draw GUI Elements
  window = ProjectNukeCoreGUIHandler.getMainWindow()
  windowSize = {window.getSize()}

  ProjectNukeCoreGUIHandler.DrawFilledBoxInWindow(colors.gray, 2, 8, windowSize[1] - 1, 17, window)

  -- Await Message
  while true do
    printMessage(awaitMessage())
  end
end

function printMessage(message)
  -- Sanity Checks
  if (message == nil) then
    return
  end

  -- Reset
  ProjectNukeCoreGUIHandler.DrawFilledBoxInWindow(colors.gray, 2, 8, windowSize[1] - 1, 17, window)
  window.setBackgroundColour(colors.gray)
  window.setTextColour(colors.white)

  -- Sanitize Message
  message = string.gsub(message, "\n", "")

  -- Split into chunks & add to buffer
  messageSplit = ProjectNukeCoreStringUtil.split(message, windowSize[1] - 2, 17)

  table.insert(messageBuffer, textutils.formatTime(os.time(), false) .. " (World Time):")
  for i, msg in ipairs(messageSplit) do
    table.insert(messageBuffer, msg)
  end

  -- Trim Message Buffer to the last 10 lines
  while (#messageBuffer > 10) do
    table.remove(messageBuffer, 1)
  end

  -- Print Message Buffer
  for i, msg in ipairs(messageBuffer) do
    window.setCursorPos(2, 7 + i)
    window.write(msg)
  end
end

function awaitMessage()
  -- Custom Copypasta from REDNET Handler
  senderId, message, protocol = rednet.receive(ProjectNukeCoreRednetHandler.REDNET_PROTOCOL_ID) 

  -- Attempt to decrypt the message
  decryptedMessage = ProjectNukeCoreEncryptionUtil.decrypt(ProjectNukeCoreConfigurationHandler.getConfig().encryptionKey, message)

  if (decryptedMessage ~= nil) then
    return decryptedMessage
  end

  -- On error, loop.
  awaitMessage()
end

function getDisplayName()
  return "REDNET Monitor"
end