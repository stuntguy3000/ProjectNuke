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

-- Maps classes to source locations
local ClassMap = {
    ["CoreObjects"] = "ProjectNukeCoreObjects.lua",
    ["CorePackets"] = "ProjectNukeCorePackets.lua",
}

-- Maps components to source locations
local ComponentsMap = {
  ["FileUtil"] = "ProjectNukeCoreFileUtil.lua",
  ["EncryptionUtil"] = "ProjectNukeCoreEncryptionUtil.lua", 
  ["GUIUtil"] = "ProjectNukeCoreGUIUtil.lua",
  ["ApplicationHandler"] = "ProjectNukeCoreApplicationHandler.lua",
  ["ConfigurationHandler"] = "ProjectNukeCoreConfigurationHandler.lua",
  ["RednetHandler"] = "ProjectNukeCoreRednetHandler.lua",
}

local ComponentsLoadOrder = {"FileUtil", "EncryptionUtil", "GUIUtil", "ApplicationHandler", "ConfigurationHandler", "RednetHandler"}

-- Core settings
local CoreComponentFolderPath = "/ProjectNuke/Core/Components/"
local CoreClassFolderPath = "/ProjectNuke/Core/Classes/"

-- Used to download the components
function DownloadCoreComponents()
  -- Delete existing core components
  fs.delete(CoreComponentFolderPath)
  
  -- Download the core components to disk
  for component, fileName in pairs(ComponentsMap) do
    fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/Components/" .. fileName
    
    shell.run("wget "..fullURL.." "..CoreComponentFolderPath..fileName)
  end
end

-- Loads the components
function LoadCoreComponents()
  for component, fileName in pairs(ComponentsMap) do
    if (fs.exists(CoreComponentFolderPath..fileName) == false) then
      error("Component "..component.." could not be found!")
    end
  end
  
  for i, component in ipairs(ComponentsLoadOrder) do
    print("Loading component "..component)
    os.loadAPI(CoreComponentFolderPath..ComponentsMap[component])  
  end
end

-- Downloads and loads external classes
function LoadClasses()
  -- Delete existing core classes
  fs.delete(CoreClassFolderPath)
  
  -- Download the core classes to disk
  for className, fileName in pairs(ClassMap) do
    fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/Classes/" .. fileName
    
    shell.run("wget "..fullURL.." "..CoreClassFolderPath..fileName)
    os.loadAPI(CoreClassFolderPath..fileName) 
  end
end

function Run()
  
end

-- Executes ProjectNukeCore
shell.run("clear")
print("===================================================")
print("Starting ProjectNuke Core...")

print("===================================================")
print("Loading classes...")
LoadClasses()
print(" ...done!")

print("===================================================")
print("Downloading components...")
DownloadCoreComponents()
print(" ...done!")

print("===================================================")
print("Loading components...")
LoadCoreComponents()
print(" ...done!")

print("===================================================")
print("Running ProjectNuke...")
Run()
shell.run("clear")