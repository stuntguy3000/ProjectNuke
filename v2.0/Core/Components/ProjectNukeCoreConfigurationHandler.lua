--[[

================================================================================

  ProjectNukeCore-ConfigurationHandler
    Provides computer configuration handling for ProjectNuke core/applications

================================================================================

  Author: stuntguy3000

--]]

local ConfigurationPath = "/ProjectNuke/config.json"

local LoadedConfiguration = {}

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
  
  LoadedConfiguration = ProjectNukeCoreClasses.Config.new("EncryptionKey", {})
  SaveConfiguration()
  
  return false
end

function SaveConfiguration()
  fs.delete(ConfigurationPath)
  ProjectNukeCoreFileUtil.SaveTable(LoadedConfiguration, ConfigurationPath)
end

-- Attempt to load the configuration, but if one is not detected, run the installer GUI
if (LoadConfiguration() == false) then
  print("New configuration detected, launching installer.")
  
  -- Create GUI
  ProjectNukeCoreGUIUtil.DrawBaseGUI("Project Nuke Installer", "Welcome to Project Nuke!")
  ProjectNukeCoreGUIUtil.SetStatus("Please select which applications to install.")
  sleep(10)
end