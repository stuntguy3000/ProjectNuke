--[[

================================================================================

  ProjectNukeApplicarionALRT
    Application: Alert & Siren Monitor

================================================================================

  Author: stuntguy3000

--]]
function run()
  ProjectNukeCoreGUIHandler.initGui(true)
  ProjectNukeCoreGUIHandler.DrawBaseGUI(getDisplayName(), nil)

  ProjectNukeCoreGUIHandler.StartEventListener()
end

function getDisplayName()
  return "Alert & Siren Monitor"
end