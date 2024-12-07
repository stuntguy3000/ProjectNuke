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
  local packetData = ProjectNukeCoreRednetHandler.WaitForPacket(ProjectNukeCorePackets.InventoryRequestStatus)
  local enabledApplication = ProjectNukeCoreConfigurationHandler.getConfig().enabledApplication

  if (enabledApplication ~= nil) then
    -- Send Response
    local responsePacket = ProjectNukeCorePackets.InventoryResponseStatus
    
    responseData = {
      [1] = enabledApplication,
    }
    
    responsePacket:setData(responseData)
    ProjectNukeCoreRednetHandler.SendPacket(responsePacket)
  end

  run()
end