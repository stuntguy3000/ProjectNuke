--[[

================================================================================

  ProjectNukeApplicarionRC
    Application: Reactor Controller

================================================================================

  Author: stuntguy3000

--]]
function run()
  ProjectNukeCoreGUIUtil.DrawBaseGUI(getDisplayName(), nil)

  ProjectNukeCoreGUIUtil.StartEventListener()
end

function getDisplayName()
  return "Reactor Controller"
end