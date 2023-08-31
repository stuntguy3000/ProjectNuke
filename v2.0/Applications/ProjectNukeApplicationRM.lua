--[[

================================================================================

  ProjectNukeApplicarionRM
    Application: Reactor Monitor

================================================================================

  Author: stuntguy3000

--]]
function run()
  ProjectNukeCoreGUIUtil.initGui(true)
  ProjectNukeCoreGUIUtil.DrawBaseGUI(getDisplayName(), nil)

  ProjectNukeCoreGUIUtil.DrawStatus("Beep boop, I'm monitoring your shit")
  ProjectNukeCoreGUIUtil.AddToggleButton("TOGGLE", "NO", 5, 12, 40, 5)

  ProjectNukeCoreGUIUtil.StartEventListener()
end

function getDisplayName()
  return "Reactor Monitor"
end