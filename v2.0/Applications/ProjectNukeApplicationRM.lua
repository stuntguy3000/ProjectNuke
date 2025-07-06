--[[

================================================================================

  ProjectNukeApplicarionRM
    Application: Reactor Monitor

================================================================================

  Author: stuntguy3000

--]]
function run()
  ProjectNukeCoreGUIHandler.initGUI(true)

  -- Prepare Graphics
  window = ProjectNukeCoreGUIHandler.getMainWindow()
  ProjectNukeCoreGUIHandler.DrawBaseGUI(getDisplayName(), nil, window)

  -- Run Server and GUI
  while true do
    parallel.waitForAny(ProjectNukeCoreGUIHandler.StartEventListener)
  end
end

function getDisplayName()
  return "Reactor Monitor - Menu"
end