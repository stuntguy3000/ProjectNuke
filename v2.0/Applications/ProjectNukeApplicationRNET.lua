--[[

================================================================================

  ProjectNukeApplicarionRNET
    Application: REDNET Monitor

    This application allows the monitoring of REDNET Communications.

================================================================================

  Author: stuntguy3000

--]]
function Run()
  term.write("===== REDNET Monitor v0.1 =====")
  term.write("Incoming messages will be printed below.")
  term.write("==========================")
  term.write("")

  while true do
    -- Custom Copypasta from REDNET Handler
    senderId, message, protocol = rednet.receive(ProjectNukeCoreRednetHandler.REDNET_PROTOCOL_ID)

    -- Attempt to decrypt the message
    decryptedMessage = ProjectNukeCoreEncryptionUtil.decrypt(ProjectNukeCoreConfigurationHandler.LoadedConfiguration.encryptionKey, message)

    if (decryptedMessage == nil) then
      term.write("Recieved message, but unable to decrypt. Ignoring...")
    else
      term.write(decryptedMessage)
    end
  end
end