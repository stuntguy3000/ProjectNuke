--[[

================================================================================

  ProjectNukeApplicarionRM
    Application: Reactor Monitor

================================================================================

  Author: stuntguy3000

--]]
function Run()
  ProjectNukeCoreGUIUtil.DrawBaseGUI("Reactor Monitor", nil)
  
  ProjectNukeCoreGUIUtil.DrawStatus("Beep boop, I'm monitoring your shit")
  ProjectNukeCoreGUIUtil.AddToggleButton("TOGGLE", "NO", 5, 12, 40, 5)
  
  ProjectNukeCoreGUIUtil.StartEventListener()
end