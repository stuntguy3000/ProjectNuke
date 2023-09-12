--[[

================================================================================

  ProjectNukeCoreBootHandler
  Provides processing for booting ProjectNuke

================================================================================

  Author: stuntguy3000

--]]

local launchConfiguration = false

function drawBootMenu()
  -- Init GUI
  ProjectNukeCoreGUIHandler.resetGUI()
  window = ProjectNukeCoreGUIHandler.getMainWindow()

  ProjectNukeCoreGUIHandler.DrawBaseGUI("Project Nuke v2.0", "Loading...", window)

  -- Labels
  window.setTextColor(colours.black)
  window.setBackgroundColor(colours.lightGrey)

  window.setCursorPos(3,12)
  window.write("Power Plant:")
  window.setCursorPos(3,13)
  window.write("Application:")
  window.setCursorPos(3,14)
  window.write("Service:")
  window.setCursorPos(3,15)
  window.write("Monitor Support:")

  -- Data
  local plantName = ProjectNukeCoreConfigurationHandler.getConfig().plantName
  local enabledApplication = ProjectNukeCoreConfigurationHandler.getConfig().enabledApplication
  local enabledService = ProjectNukeCoreConfigurationHandler.getConfig().enabledService
  local monitorSupport = ProjectNukeCoreConfigurationHandler.getConfig().monitorSupport

  -- Power Plant
  window.setTextColor(colours.grey)
  window.setCursorPos(20,12)
  window.write(plantName)

  -- Enabled Application
  window.setCursorPos(20,13)
  window.write(_G[enabledApplication]:getDisplayName())

  -- Enabled Service
  window.setCursorPos(20,14)
  if (enabledService ~= nil) then
    window.write(_G[enabledService]:getDisplayName())
  else
    window.write("None")
  end

  -- Monitor Support
  window.setCursorPos(20,15)
  if (monitorSupport) then
    window.setTextColor(colours.blue)
    window.write("Yes")
  else
    window.setTextColor(colours.red)
    window.write("No")
  end

  -- Buttons
  ProjectNukeCoreGUIHandler.AddButton("Open Configuration Menu", nil, "Open Configuration Menu", colours.white, colours.blue, 12, 17, 29, 1, setLaunchConfiguration, window)
  parallel.waitForAny(updateStatus, ProjectNukeCoreGUIHandler.StartEventListener)

  if (launchConfiguration) then
    launchConfigurationMenu()
  end
end

function tryBoot()
  -- Attempt to load the configuration, but if one is not detected, run the installer GUI
  if (ProjectNukeCoreConfigurationHandler.LoadConfiguration() == false) then
    print("New configuration detected, launching installer.")
    launchConfigurationMenu()
  else
    print("Booting...")
    drawBootMenu()
  end
end

function launchConfigurationMenu()
  ProjectNukeCoreGUIHandler.resetGUI()
  ProjectNukeCoreConfigurationHandler.drawConfigurationMenu(1)
end

function setLaunchConfiguration()
  launchConfiguration = true
end

function updateStatus()
  -- Countdown Timer
  for i = 3, 1, -1 do
    ProjectNukeCoreGUIHandler.WriteStatus("Starting in " .. i .. "...")
    sleep(1)
  end
end

tryBoot()