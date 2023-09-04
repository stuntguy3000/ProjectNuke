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
  ProjectNukeCoreGUIHandler.DrawBaseGUI(getDisplayName(), nil, window)
  
  sleep(1)

  -- Authentication Gateway
  ProjectNukeCoreAuthenticationHandler.requestAuthentication(true)

  ProjectNukeCoreGUIHandler.StartEventListener()
end

function getDisplayName()
  return "Reactor Controller"
end