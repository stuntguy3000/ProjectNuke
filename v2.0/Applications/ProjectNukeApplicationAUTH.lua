--[[

================================================================================

  ProjectNukeApplicarionAUTH
    Application: Authentication Server

================================================================================

  Author: stuntguy3000

--]]
function run()
  ProjectNukeCoreGUIUtil.initGui(true)
  ProjectNukeCoreGUIUtil.DrawBaseGUI(getDisplayName(), nil)

  ProjectNukeCoreGUIUtil.StartEventListener()
end

function getDisplayName()
  return "Authentication Server"
end