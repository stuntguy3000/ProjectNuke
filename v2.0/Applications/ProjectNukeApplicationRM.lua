--[[

================================================================================

  ProjectNukeApplicarionRM
    Application: Reactor Monitor

================================================================================

  Author: stuntguy3000

--]]
function run()
  ProjectNukeCoreGUIHandler.initGui(true)
  ProjectNukeCoreGUIHandler.DrawBaseGUI(getDisplayName(), nil)

  ProjectNukeCoreGUIHandler.DrawStatus("Beep boop, I'm monitoring your shit")
  ProjectNukeCoreGUIHandler.AddToggleButton("TOGGLE", "NO", 5, 12, 40, 5)

  ProjectNukeCoreGUIHandler.StartEventListener()
end

function getDisplayName()
  return "Reactor Monitor"
end