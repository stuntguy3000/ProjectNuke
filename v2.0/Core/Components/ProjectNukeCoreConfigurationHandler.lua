--[[

================================================================================

  ProjectNukeCore-ConfigurationHandler
    Provides computer configuration handling for ProjectNuke core/applications

================================================================================

  Author: stuntguy3000

--]]

local ConfigurationPath = "/ProjectNuke/config.json"

local LoadedConfiguration = nil

-- Returns true if a valid configuration was found, false if one was created.
function LoadConfiguration()
  validConfig = false
  
  if (fs.exists(ConfigurationPath) == true) then
    configTable = ProjectNukeCoreFileUtil.LoadTable(ConfigurationPath)
    
    LoadedConfiguration = ProjectNukeCoreClasses.Config.new(configTable['encryptionKey'], configTable['enabledApplications'])
  end
  
  if (LoadedConfiguration ~= null and LoadedConfiguration:isValid()) then
    return false;
  end
  
  LoadedConfiguration = ProjectNukeCoreClasses.Config.new("EncryptionKey", {})
  SaveConfiguration()
  
  return false
end

function SaveConfiguration()
  fs.delete(ConfigurationPath)
  ProjectNukeCoreFileUtil.SaveTable(LoadedConfiguration, ConfigurationPath)
end

function LaunchConfigurationMenu(pageNumber)
  term.clear()
  if (pageNumber == 1) then
  
    -- Create GUI
    ProjectNukeCoreGUIUtil.DrawBaseGUI("Project Nuke Installer", "Welcome to Project Nuke!")
	ProjectNukeCoreGUIUtil.DrawStatus("Please select which applications to install.")
  
    -- Labels
    term.setTextColor(colors.gray)
    term.setBackgroundColor(colors.lightGray)

    term.setCursorPos(8,11) 
    term.write("Access Control Client (ACC)")
    term.setCursorPos(8,12) 
    term.write("Access Control Server (ACS)")
    term.setCursorPos(8,13) 
    term.write("Emergency Alert System Client (EASC)")
    term.setCursorPos(8,14) 
    term.write("Emergency Alert System Server (EASS)")
    term.setCursorPos(8,15) 
    term.write("Reactor Monitoring (RM)")
    term.setCursorPos(8,16) 
    term.write("Reactor Controller (RC)")
    
    -- Buttons
    ProjectNukeCoreGUIUtil.AddToggleButton("ACC", "NO", 2, 11, 5, 1)
    ProjectNukeCoreGUIUtil.AddToggleButton("ACS", "NO", 2, 12, 5, 1)
    ProjectNukeCoreGUIUtil.AddToggleButton("EASC", "NO", 2, 13, 5, 1)
    ProjectNukeCoreGUIUtil.AddToggleButton("EASS", "YES",  2, 14, 5, 1)
    ProjectNukeCoreGUIUtil.AddToggleButton("RM", "NO", 2, 15, 5, 1)
    ProjectNukeCoreGUIUtil.AddToggleButton("RC", "NO",  2, 16, 5, 1)
    
    ProjectNukeCoreGUIUtil.AddButton("Continue", nil, "Continue", colours.white, colours.blue, 41, 17, 10, 1, nil)
    
    ProjectNukeCoreGUIUtil.StartEventListener()
  elseif (pageNumber == 2) then
  
  end
end

-- Attempt to load the configuration, but if one is not detected, run the installer GUI
if (LoadConfiguration() == false) then
  print("New configuration detected, launching installer.")
  LaunchConfigurationMenu(1)
end