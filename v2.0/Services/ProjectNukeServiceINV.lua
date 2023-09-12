--[[

================================================================================

  ProjectNukeServiceINV
    Provides a way for a ProjectNuke to inventory all computers on the network.

    TODO

================================================================================

  Author: stuntguy3000

--]]

function getDisplayName()
  return "Computer Inventory Service"
end

function run()
  local packetData = ProjectNukeCoreRednetHandler.WaitForPacket(emergencyStatePacket:getID())

end