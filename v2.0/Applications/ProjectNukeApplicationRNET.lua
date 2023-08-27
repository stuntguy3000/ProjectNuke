--[[

================================================================================

  ProjectNukeApplicarionRNET
    Application: REDNET Monitor

    This application allows the monitoring of REDNET Communications.

================================================================================

  Author: stuntguy3000

--]]
function run()
  print("========== REDNET Monitor v0.1 ==========")
  print("Incoming messages will be printed below.")
  print("========================================")
  print("")

  while true do
    -- Custom Copypasta from REDNET Handler
    senderId, message, protocol = rednet.receive(ProjectNukeCoreRednetHandler.REDNET_PROTOCOL_ID)

    -- Attempt to decrypt the message
    decryptedMessage = ProjectNukeCoreEncryptionUtil.decrypt(ProjectNukeCoreConfigurationHandler.LoadedConfiguration.encryptionKey, message)

    if (decryptedMessage == nil) then
      print("Recieved message, but unable to decrypt. Ignoring...")
    else
      print(decryptedMessage)
    end
  end
end

function getDisplayName()
  return "REDNET Monitor"
end