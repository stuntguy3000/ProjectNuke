--[[

================================================================================

  ProjectNukeApplicarionALRT
    Application: Alert & Siren Monitor

================================================================================

  Author: stuntguy3000

--]]
function run()
  ProjectNukeCoreGUIUtil.DrawBaseGUI(getDisplayName(), nil)

  ProjectNukeCoreGUIUtil.StartEventListener()
end

function getDisplayName()
  return "Alert & Siren Monitor"
end