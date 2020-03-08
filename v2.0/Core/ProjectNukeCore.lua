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

-- Maps components to source locations
local ComponentsMap = {
  ["EncryptionUtil"] = "ProjectNukeCore-EncryptionUtil.lua", 
  ["GUIUtil"] = "ProjectNukeCore-GUIUtil.lua",
  ["FileUtil"] = "ProjectNukeCore-FileUtil.lua"
}

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

-- Executes the installed Project Nuke application
function ExecuteApplication()
  
end

-- Executes ProjectNukeCore
shell.run("clear")
print("Starting ProjectNuke Core...")
DownloadCoreComponents()
ExecuteApplication()