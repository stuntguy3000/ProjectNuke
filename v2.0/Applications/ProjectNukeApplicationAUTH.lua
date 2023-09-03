--[[

================================================================================

  ProjectNukeApplicarionAUTH
    Application: Authentication Server

================================================================================

  Author: stuntguy3000

--]]
function run()
  -- Init GUI
  ProjectNukeCoreGUIHandler.initGui(false)
  ProjectNukeCoreGUIHandler.DrawBaseGUI(getDisplayName(), nil)


  -- Wrap it up
  ProjectNukeCoreGUIHandler.StartEventListener()
end

function getDisplayName()
  return "Authentication Server"
end