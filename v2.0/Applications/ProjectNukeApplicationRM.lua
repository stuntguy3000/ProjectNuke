--[[

================================================================================

  ProjectNukeApplicarionRM
    Application: Reactor Monitor

================================================================================

  Author: stuntguy3000

--]]
function run()
  ProjectNukeCoreGUIHandler.initGUI(true)

  -- Prepare Graphics
  window = ProjectNukeCoreGUIHandler.getMainWindow()
  ProjectNukeCoreGUIHandler.DrawBaseGUI(getDisplayName(), nil, window)

  -- Prepare Menu
  menuTest1 = ProjectNukeCoreClassesGUI.Menu.new("Left", window, 2, 8, 20, 7)
  for i=1,30 do
    menuTest1:addItem("Item " .. i, "Button " .. i, colours.red, nil, nil)
  end
  menuTest1:render()

  -- Prepare Menu
  menuTest2 = ProjectNukeCoreClassesGUI.Menu.new("Right", window, 30, 8, 20, 3)
  for i=1,15 do
    menuTest2:addItem("Item " .. i, "Button " .. i, colours.blue, nil, nil)
  end
  menuTest2:render()

  -- Prepare Menu
  menuTest2 = ProjectNukeCoreClassesGUI.Menu.new("Bottom", window, 30, 14, 20, 3)
  for i=1,85 do
    menuTest2:addItem("Item " .. i, "Button " .. i, colours.green, nil, nil)
  end
  menuTest2:render()

  -- Run Server and GUI
  while true do
    parallel.waitForAny(ProjectNukeCoreGUIHandler.StartEventListener)
  end
end

function getDisplayName()
  return "Reactor Monitor - Menu"
end