--[[

================================================================================

  ProjectNukeCore-ConfigurationHandler
    Provides computer configuration handling for ProjectNuke core/applications

================================================================================

  Author: stuntguy3000

--]]

local ConfigurationPath = "/ProjectNuke/config.json"

LoadedConfiguration = nil
local CurrentMenuPageNumber = 0

-- Returns true if a valid configuration was found, false if one was created.
function LoadConfiguration()
  validConfig = false
  
  if (fs.exists(ConfigurationPath) == true) then
    configTable = ProjectNukeCoreFileUtil.LoadTable(ConfigurationPath)
    
    LoadedConfiguration = ProjectNukeCoreClasses.Config.new(configTable['encryptionKey'], configTable['enabledApplications'])
  end
  
  if (LoadedConfiguration ~= null and LoadedConfiguration:isValid()) then
    return true;
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
  ProjectNukeCoreGUIUtil.ClearGUI(window)
  
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
    
    -- Labels
    window.setCursorPos(2,11) 
    window.write("Shared Encryption Key:")
	  window.setCursorPos(2,14) 
    window.write("All applications in Project Nuke use Rednet to")
	  window.setCursorPos(2,15) 
    window.write("communicate. Project Nuke implements AES 128")
	  window.setCursorPos(2,16) 
    window.write("encryption ensure system security.")
    
    -- Buttons
    ProjectNukeCoreGUIUtil.AddButton("Continue", nil, "Continue", colours.white, colours.blue, 41, 17, 10, 1, ConfigurationMenuContinue)
    ProjectNukeCoreGUIUtil.UpdateTextbox(ProjectNukeCoreGUIUtil.AddTextbox("EncryptionKeyInput", 2, 12, 48))
	
    ProjectNukeCoreGUIUtil.StartEventListener()
  elseif (nextPageNumber == 3) then
    CurrentMenuPageNumber = 3
    
    -- Create GUI
    ProjectNukeCoreGUIUtil.DrawBaseGUI("Project Nuke Installer - Step 3/3", "Welcome to Project Nuke!")
	  ProjectNukeCoreGUIUtil.DrawStatus("Installation completed.")
    
    -- Labels
    window.setCursorPos(2,11) 
    window.setTextColour(colours.white)
    window.write("Thanks for installing Project Nuke!")
    window.setTextColour(colours.grey)
	  window.setCursorPos(2,13) 
    window.write("Please setup all your other computers with various")
	  window.setCursorPos(2,14) 
    window.write("Project Nuke applications and begin generating")
	  window.setCursorPos(2,15) 
    window.write("safe, clean and efficient nuclear power!")
    
    
	  window.setCursorPos(2,17) 
    window.write("To begin, click Finish.")
    
    -- Buttons
    ProjectNukeCoreGUIUtil.AddButton("Finish", nil, "Finish", colours.white, colours.green, 41, 17, 10, 1, ConfigurationMenuContinue)
	
    ProjectNukeCoreGUIUtil.StartEventListener()
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
      if (v:getValue() == "YES" or v:getValue() == "Yes") then
        table.insert(EnabledApplications, v:getID())
      else
        table.insert(DisabledApplications, v:getID())
      end
    end
    
    if (table.getn(EnabledApplications) == 0) then
      ProjectNukeCoreGUIUtil.DrawErrorMessages({[10] = "Error: Please select applications to install."}, 3)
	    ProjectNukeCoreGUIUtil.StartEventListener()
      return nil
    else
      LoadedConfiguration.setEnabledApplications(EnabledApplications)
      SaveConfiguration()
      
      LaunchConfigurationMenu(2)
      CurrentMenuPageNumber = 2
    end
  elseif (CurrentMenuPageNumber == 2) then
      -- Store value from EncryptionKey textbox
      EncryptionKeyTextbox = ProjectNukeCoreGUIUtil.GetClickableItemByID("EncryptionKeyInput");
      
	  if (EncryptionKeyTextbox == nil) then
	    ProjectNukeCoreGUIUtil.DrawErrorMessages({[10] = "Error: Please enter a Encryption Key."}, 3)
	    ProjectNukeCoreGUIUtil.StartEventListener()
		
		return nil
	  end
	  
	  EncryptionKey = EncryptionKeyTextbox:getValue()
	  
	  if (EncryptionKey == nil or EncryptionKey == "") then
	    ProjectNukeCoreGUIUtil.DrawErrorMessages({[10] = "Error: Please enter a Encryption Key."}, 3)
	    ProjectNukeCoreGUIUtil.StartEventListener()
		
		return nil
	  end
	  
      LoadedConfiguration:setEncryptionKey(EncryptionKey)
      SaveConfiguration()
      
      LaunchConfigurationMenu(3)
      CurrentMenuPageNumber = 3
  end
end

-- Attempt to load the configuration, but if one is not detected, run the installer GUI
if (LoadConfiguration() == false) then
  print("New configuration detected, launching installer.")
  LaunchConfigurationMenu(1)
end