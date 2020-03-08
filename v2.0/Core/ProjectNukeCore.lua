--[[

================================================================================

  ProjectNukeCore
    Provides core functionalities/shared libraries used by every ProjectNuke application. 
    This file is downloaded by ProjectNukeLauncher on runtime to ensure up to date libraries/core functionalities.
    
    Functions include:
      - Common GUI handling
      - Emergency/Alert handling/display
      - REDNET handling

================================================================================

  Author: stuntguy3000

--]]

_G["shell"] = shell 

-- Maps components to source locations
local ComponentsMap = {
  ["FileUtil"] = "ProjectNukeCoreFileUtil.lua",
  ["EncryptionUtil"] = "ProjectNukeCoreEncryptionUtil.lua", 
  ["GUIUtil"] = "ProjectNukeCoreGUIUtil.lua",
  ["ApplicationHandler"] = "ProjectNukeCoreApplicationHandler.lua",
  ["ConfigurationHandler"] = "ProjectNukeCoreConfigurationHandler.lua",
}

local ComponentsLoadOrder = {"FileUtil", "EncryptionUtil", "ConfigurationHandler", "GUIUtil", "ApplicationHandler"}

-- Core settings
local CoreFolderPath = "/ProjectNuke/Core/Components/"

-- Used to download the components
function DownloadCoreComponents()
  -- Delete existing core components
  fs.delete(CoreFolderPath)
  
  -- Download the core components to disk
  for component, fileName in pairs(ComponentsMap) do
    fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/Components/" .. fileName
    
    shell.run("wget "..fullURL.." "..CoreFolderPath..fileName)
  end
end

-- Loads the components
function LoadCoreComponents()
  for component, fileName in pairs(ComponentsMap) do
    if (fs.exists(CoreFolderPath..fileName) == false) then
      error("Component "..component.." could not be found!")
    end
  end
  
  for i, component in ipairs(ComponentsLoadOrder) do
    print("Loading component "..component)
    os.loadAPI(CoreFolderPath..ComponentsMap[component])  
  end
end

function RunApplications()
  
end

-- Executes ProjectNukeCore
shell.run("clear")
print("==================================================")
print("Starting ProjectNuke Core...")

print("==================================================")
print("Downloading components...")
DownloadCoreComponents()
print(" ...done!")

print("==================================================")
print("Loading components...")
LoadCoreComponents()
print(" ...done!")

print("==================================================")
print("Running ProjectNuke Applications...")
RunApplications()
shell.run("clear")