--[[

================================================================================

  ProjectNukeApplicarionINV
    Application: Inventory

================================================================================

  Author: stuntguy3000

--]]
knownApplications = {}

y = 8

function run()
  -- Prepare Graphics
  ProjectNukeCoreGUIHandler.initGUI(false)
  window = ProjectNukeCoreGUIHandler.getMainWindow()
  ProjectNukeCoreGUIHandler.DrawBaseGUI(getDisplayName(), nil, window)

  ProjectNukeCoreGUIHandler.AddButton("Test", nil, "Test", colours.red, colours.lightGrey, 3, 8, 6, 1, sendInventoryRequest, window)

  -- Run Server and GUI
  while true do
    parallel.waitForAny(runInventoryServer, ProjectNukeCoreGUIHandler.StartEventListener)
  end
end

function getDisplayName()
  return "Utility - Inventory"
end

function sendInventoryRequest()
  ProjectNukeCoreRednetHandler.SendPacket(ProjectNukeCorePackets.InventoryRequestStatus)
end

function runInventoryServer()
  -- Await InventoryResponseStatus
  local packet = ProjectNukeCoreRednetHandler.WaitForPacket(ProjectNukeCorePackets.InventoryResponseStatus)

  if (packet ~= nil) then
    -- Process
    local packetData = packet:getData()
    local enabledApplication = packetData[1]

    y = y + 1
    window.setCursorPos(2, y)
    window.write(enabledApplication)
  end  
end