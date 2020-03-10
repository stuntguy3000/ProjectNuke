--[[

================================================================================

  ProjectNukeCore-ConfigurationHandler
    Provides computer configuration handling for ProjectNuke core/applications

================================================================================

  Author: stuntguy3000

--]]

local ConfigurationPath = "/ProjectNuke/config.json"

local LoadedConfiguration = nil
local CurrentMenuPageNumber = 0

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
  
  LoadedConfiguration = ProjectNukeCoreClasses.Config.new("", {})
  SaveConfiguration()
  
  return false
end

function SaveConfiguration()
  fs.delete(ConfigurationPath)
  ProjectNukeCoreFileUtil.SaveTable(LoadedConfiguration, ConfigurationPath)
end

function LaunchConfigurationMenu(nextPageNumber)
  window = ProjectNukeCoreGUIUtil.ProjectNukeGUI
  ProjectNukeGUI.ClearGUI(window)
  
  if (nextPageNumber == 1) then
    CurrentMenuPageNumber = 1
    
    -- Create GUI
    ProjectNukeCoreGUIUtil.DrawBaseGUI("Project Nuke Installer - Step 1/3", "Welcome to Project Nuke!")
	  ProjectNukeCoreGUIUtil.DrawStatus("Please select which applications to install.")
  
    -- Labels
    window.setTextColor(colours.grey)
    window.setBackgroundColor(colours.lightGrey)

    window.setCursorPos(8,11) 
    window.write("Access Control Client (ACC)")
    window.setCursorPos(8,12) 
    window.write("Access Control Server (ACS)")
    window.setCursorPos(8,13) 
    window.write("Emergency Alert System Client (EASC)")
    window.setCursorPos(8,14) 
    window.write("Emergency Alert System Server (EASS)")
    window.setCursorPos(8,15) 
    window.write("Reactor Monitoring (RM)")
    window.setCursorPos(8,16) 
    window.write("Reactor Controller (RC)")
    
    -- Buttons
    ProjectNukeCoreGUIUtil.AddToggleButton("ACC", "NO", 2, 11, 5, 1)
    ProjectNukeCoreGUIUtil.AddToggleButton("ACS", "NO", 2, 12, 5, 1)
    ProjectNukeCoreGUIUtil.AddToggleButton("EASC", "YES", 2, 13, 5, 1)
    ProjectNukeCoreGUIUtil.AddToggleButton("EASS", "NO",  2, 14, 5, 1)
    ProjectNukeCoreGUIUtil.AddToggleButton("RM", "NO", 2, 15, 5, 1)
    ProjectNukeCoreGUIUtil.AddToggleButton("RC", "NO",  2, 16, 5, 1)
    
    ProjectNukeCoreGUIUtil.AddButton("Continue", nil, "Continue", colours.white, colours.blue, 41, 17, 10, 1, ConfigurationMenuContinue)
    
    ProjectNukeCoreGUIUtil.StartEventListener()
  elseif (nextPageNumber == 2) then
    CurrentMenuPageNumber = 2
    
    -- Create GUI
    ProjectNukeCoreGUIUtil.DrawBaseGUI("Project Nuke Installer - Step 2/3", "Welcome to Project Nuke!")
	  ProjectNukeCoreGUIUtil.DrawStatus("Please enter the shared encryption key.")
    
    window.setCursorPos(2,11) 
    window.write("Shared Encryption Key:")
	  ProjectNukeCoreGUIUtil.AddTextInput("EncryptionKey", 2, 11, 5)
	
	  window.setCursorPos(2,14) 
    window.write("All applications in Project Nuke use Rednet to")
	  window.setCursorPos(2,15) 
    window.write("communicate. Project Nuke implements AES 128")
	  window.setCursorPos(2,16) 
    window.write("encryption ensure system security.")
    
  -- Buttons
  ProjectNukeCoreGUIUtil.AddButton("Continue", nil, "Continue", colours.white, colours.blue, 41, 17, 10, 1, ConfigurationMenuContinue)
	
	ProjectNukeCoreGUIUtil.StartEventListener()
  elseif (nextPageNumber == 3) then
    CurrentMenuPageNumber = 3
    
  end
end

-- Configuration menu page continue
function ConfigurationMenuContinue()
  if (CurrentMenuPageNumber == 1) then
    -- Validate applications are actually selected
    ToggleButtons = ProjectNukeCoreGUIUtil.GetToggleButtons();
    DisabledApplications = {}
    EnabledApplications = {}
    
    for i, v in pairs(ToggleButtons) do
      if (v:getValue() == "YES") then
        table.insert(EnabledApplications, v:getID())
      else
        table.insert(DisabledApplications, v:getID())
      end
    end
    
    if (table.getn(EnabledApplications) == 0) then
      ProjectNukeCoreGUIUtil.DrawErrorMessages({[10] = "Error: Please select applications to install."}, 3)
	    ProjectNukeCoreGUIUtil.StartEventListener()
    else
      LoadedConfiguration.setEnabledApplications(EnabledApplications)
      SaveConfiguration()
      
      LaunchConfigurationMenu(2)
      CurrentMenuPageNumber = 2
    end
  elseif (CurrentMenuPageNumber == 2) then
    return
  elseif (CurrentMenuPageNumber == 3) then
    return
  end
  
  CurrentMenuPageNumber = 0
end

-- Attempt to load the configuration, but if one is not detected, run the installer GUI
if (LoadConfiguration() == false) then
  print("New configuration detected, launching installer.")
  LaunchConfigurationMenu(1)
end