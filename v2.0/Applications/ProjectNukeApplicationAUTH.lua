--[[

================================================================================

  ProjectNukeApplicarionAUTH
    Application: Authentication Server

================================================================================

  Author: stuntguy3000

--]]
function run()
  -- Init GUI
  ProjectNukeCoreGUIHandler.initGUI(false)
  
  mainWindow = ProjectNukeCoreGUIHandler.getMainWindow()
  ProjectNukeCoreGUIHandler.DrawBaseGUI(getDisplayName(), nil, mainWindow)


  -- Wrap it up
  ProjectNukeCoreGUIHandler.StartEventListener()
end

function getDisplayName()
  return "Authentication Server"
end