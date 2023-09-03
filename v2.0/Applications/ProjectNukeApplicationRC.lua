--[[

================================================================================

  ProjectNukeApplicarionRC
    Application: Reactor Controller

================================================================================

  Author: stuntguy3000

--]]
function run()
  ProjectNukeCoreGUIHandler.initGui(true)
  ProjectNukeCoreGUIHandler.DrawBaseGUI(getDisplayName(), nil)

  ProjectNukeCoreGUIHandler.StartEventListener()
end

function getDisplayName()
  return "Reactor Controller"
end