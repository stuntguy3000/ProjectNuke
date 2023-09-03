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
  ProjectNukeCoreGUIUtil.clearGUI()
  window = ProjectNukeCoreGUIUtil.getMainWindow()

  ProjectNukeCoreGUIUtil.DrawBaseGUI("Project Nuke v2.0", "Loading...")

  -- Labels
  window.setTextColor(colours.black)
  window.setBackgroundColor(colours.lightGrey)

  window.setCursorPos(2,11)
  window.write("Enabled Application:")
  window.setCursorPos(2,14)
  window.write("Enabled Service:")

  -- Data
  local enabledApplication = ProjectNukeCoreConfigurationHandler.getConfig().enabledApplication
  local enabledService = ProjectNukeCoreConfigurationHandler.getConfig().enabledService

  window.setTextColor(colours.grey)
  window.setCursorPos(2,12)
  window.write(_G[enabledApplication]:getDisplayName())

  window.setCursorPos(2,15)
  if (enabledService ~= nil) then
    window.write(_G[enabledService]:getDisplayName())
  else
    window.setTextColor(colours.red)
    window.write("None")
  end

  -- Buttons
  ProjectNukeCoreGUIUtil.AddButton("Open Configuration Menu", nil, "Open Configuration Menu", colours.white, colours.blue, 12, 17, 29, 1, setLaunchConfiguration)
  parallel.waitForAny(updateStatus, ProjectNukeCoreGUIUtil.StartEventListener)

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
  ProjectNukeCoreConfigurationHandler.drawConfigurationMenu(1)
end

function setLaunchConfiguration()
  launchConfiguration = true
end

function updateStatus()
  -- Countdown Timer
  for i = 3, 1, -1 do
    ProjectNukeCoreGUIUtil.DrawStatus("Starting in " .. i .. "...")
    sleep(1)
  end
end

tryBoot()