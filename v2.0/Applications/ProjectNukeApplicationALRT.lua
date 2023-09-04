--[[

================================================================================

  ProjectNukeApplicarionALRT
    Application: Alert & Siren Monitor

================================================================================

  Author: stuntguy3000

--]]
function run()
  ProjectNukeCoreGUIHandler.initGUI(true)

  mainWindow = ProjectNukeCoreGUIHandler.getMainWindow()
  ProjectNukeCoreGUIHandler.DrawBaseGUI(getDisplayName(), nil, mainWindow)

  ProjectNukeCoreGUIHandler.StartEventListener()
end

function getDisplayName()
  return "Alert & Siren Monitor"
end