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

-- Maps classes to source locations
local ClassMap = {
  "ProjectNukeCoreClasses.lua",
  "ProjectNukeCorePackets.lua",
}

-- Maps handlers to source locations
local HandlersMap = {
  "ProjectNukeCoreApplicationHandler.lua",
  "ProjectNukeCoreServiceHandler.lua",
  "ProjectNukeCoreConfigurationHandler.lua",
  "ProjectNukeCoreRednetHandler.lua",
}

-- Maps utility functions to source locations
local UtilMap = {
  "ProjectNukeCoreFileUtil.lua",
  "ProjectNukeCoreEncryptionUtil.lua",
  "ProjectNukeCoreGUIUtil.lua",
}

-- Core settings 
local CoreHandlerFolderPath = "/ProjectNuke/Core/Handlers/"
local CoreUtilFolderPath = "/ProjectNuke/Core/Util/"
local CoreClassFolderPath = "/ProjectNuke/Core/Classes/"

-- ===== START FUNCTIONS =====

-- Used to download the Handlers
function DownloadCoreHandlers()
  -- Delete existing core Handlers
  fs.delete(CoreHandlerFolderPath)

  -- Download the core Handlers to disk
  for i, fileName in ipairs(HandlersMap) do
    fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/Handlers/" .. fileName

    -- Execute
    shell.run("wget "..fullURL.." "..CoreHandlerFolderPath..fileName)
  end
end

-- Loads the Handlers
function LoadCoreHandlers()
  for i, fileName in ipairs(HandlersMap) do
    tryLoadAPI(CoreHandlerFolderPath .. fileName)
  end
end

function DownloadClasses()
  -- Delete existing core classes
  fs.delete(CoreClassFolderPath)

  -- Download the core classes to disk
  for i, fileName in ipairs(ClassMap) do
    fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/Classes/" .. fileName

    -- Execute
    shell.run("wget "..fullURL.." "..CoreClassFolderPath..fileName)
  end
end

function LoadClasses()
  for i, fileName in ipairs(ClassMap) do
    tryLoadAPI(CoreClassFolderPath  .. fileName)
  end
end

function DownloadUtil()
  -- Delete existing core util
  fs.delete(CoreUtilFolderPath)

  -- Download the core classes to disk
  for i, fileName in ipairs(UtilMap) do
    fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/Util/" .. fileName

    shell.run("wget "..fullURL.." "..CoreUtilFolderPath..fileName)
  end
end

-- Downloads and loads external util
function LoadUtil()
  for i, fileName in ipairs(UtilMap) do
    tryLoadAPI(CoreUtilFolderPath  ..  fileName)
  end
end

-- Attempt to load an API File into the OS
function tryLoadAPI(filePath)
  local loaded = os.loadAPI(filePath)

  if (loaded == false) then
    error("API ".. filePath .." could not be loaded!")
  else
    print("API " .. filePath .. " loaded.")
  end
    
end

function RunApplication()
  if (doRun) then
    term.clear()
    term.setCursorPos(1,1)

    parallel.waitForAll(ProjectNukeCoreServiceHandler.tryRunServices, ProjectNukeCoreApplicationHandler.tryRunApplications)

    print("Execution completed. Rebooting")
    sleep(5)

    RunApplication() -- TODO: Validate this behavior as intended
  end
end

-- ===== END FUNCTIONS =====

-- Executes ProjectNukeCore
_G["shell"] = shell

-- Arguments Processing
doRun = true
doDownload = true
if (arg[1] == "NODOWNLOAD") then
  doDownload = false
elseif (arg[1] == "LOADONLY") then
  doDownload = false
  doRun = false
end

-- Terminal Setup
term.clear()
term.setCursorPos(1,1)

-- Download content, if needed
if (doDownload) then
  print(" >> Downloading Content <<")
  DownloadClasses()
  DownloadUtil()
  DownloadCoreHandlers()

  -- Hijack and load these services
  tryLoadAPI(CoreHandlerFolderPath .. HandlersMap[1]) -- Application Handler
  tryLoadAPI(CoreHandlerFolderPath .. HandlersMap[2]) -- Service Handler

  ProjectNukeCoreApplicationHandler.downloadApplications()
  ProjectNukeCoreServiceHandler.downloadServices()
end

print(" >> Loading... <<")

-- Load Classes
LoadClasses()
LoadUtil()

-- Initalize Handlers
LoadCoreHandlers()

-- Launch!
print(" >> Launching ProjectNuke <<")
RunApplication()