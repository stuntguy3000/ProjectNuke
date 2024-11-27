--[[

================================================================================

  ProjectNukeApplicarionRC
    Application: Reactor Controller

================================================================================

  Author: stuntguy3000

--]]
function run()
  ProjectNukeCoreGUIHandler.initGUI(true)
  window = ProjectNukeCoreGUIHandler.getMainWindow()

  -- Authentication Gateway
  ProjectNukeCoreAuthenticationHandler.requestAuthentication(false)

  ProjectNukeCoreGUIHandler.DrawBaseGUI(getDisplayName(), nil, window)
  ProjectNukeCoreGUIHandler.StartEventListener()
end

function getDisplayName()
  return "Reactor Controller"
end