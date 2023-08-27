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
    ["CoreClasses"] = "ProjectNukeCoreClasses.lua",
    ["CorePackets"] = "ProjectNukeCorePackets.lua",
}

-- Maps handlers to source locations
local HandlersMap = {
  ["ApplicationHandler"] = "ProjectNukeCoreApplicationHandler.lua",
  ["ConfigurationHandler"] = "ProjectNukeCoreConfigurationHandler.lua",
  ["RednetHandler"] = "ProjectNukeCoreRednetHandler.lua",
  ["ServiceHandler"] = "ProjectNukeCoreServiceHandler.lua",
}

-- Maps utility functions to source locations
local UtilMap = {
  ["FileUtil"] = "ProjectNukeCoreFileUtil.lua",
  ["EncryptionUtil"] = "ProjectNukeCoreEncryptionUtil.lua",
  ["GUIUtil"] = "ProjectNukeCoreGUIUtil.lua",
}

-- Defines the order to load class and handlers
local ClassLoadOrder = {"CoreClasses", "CorePackets"}
local HandlersLoadOrder = {"ApplicationHandler", "ServiceHandler", "ConfigurationHandler", "RednetHandler"}

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
  for handlerID, fileName in pairs(HandlersMap) do
    fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/Handlers/" .. fileName

    -- Execute
    shell.run("wget "..fullURL.." "..CoreHandlerFolderPath..fileName)
  end
end

-- Loads the Handlers
function LoadCoreHandlers()
  for i, handlerID in ipairs(HandlersLoadOrder) do
    print("")
    print("Loading Handler "..handlerID)
    print(CoreHandlerFolderPath .. HandlersMap[handlerID])
    print("")
    tryLoadAPI(Handler, CoreHandlerFolderPath .. HandlersMap[handlerID])
  end
end

function DownloadClasses()
  -- Delete existing core classes
  fs.delete(CoreClassFolderPath)

  -- Download the core classes to disk
  for className, fileName in pairs(ClassMap) do
    fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/Classes/" .. fileName

    -- Execute
    shell.run("wget "..fullURL.." "..CoreClassFolderPath..fileName)
  end
end

function LoadClasses()
  for i, Class in ipairs(ClassLoadOrder) do
    tryLoadAPI(Class, CoreClassFolderPath..ClassMap[Class])
  end
end

function DownloadUtil()
  -- Delete existing core util
  fs.delete(CoreUtilFolderPath)

  -- Download the core classes to disk
  for utilID, fileName in pairs(UtilMap) do
    fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/Util/" .. fileName

    shell.run("wget "..fullURL.." "..CoreUtilFolderPath..fileName)
  end
end

-- Downloads and loads external util
function LoadUtil()
  for utilID, fileName in pairs(UtilMap) do
    tryLoadAPI(utilID, CoreUtilFolderPath..fileName)
  end
end

-- Attempt to load an API File into the OS
function tryLoadAPI(friendlyName, filepath)
  local loaded = os.loadAPI(filepath)

  if (loaded == false) then
    error("API "..friendlyName.." could not be loaded!")
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
  tryLoadAPI(Handler, CoreHandlerFolderPath .. HandlersMap["ApplicationHandler"])
  tryLoadAPI(Handler, CoreHandlerFolderPath .. HandlersMap["ServiceHandler"])

  ProjectNukeCoreApplicationHandler.downloadApplications()
  ProjectNukeCoreServiceHandler.downloadServices()
end

print(" >> Loading... <<")

-- Load Classes
LoadClasses()
LoadUtil()

-- Initalize Handlers
ProjectNukeCoreApplicationHandler.loadApplications()
ProjectNukeCoreServiceHandler.loadServices()

LoadCoreHandlers()

-- Launch!
print(" >> Launching ProjectNuke <<")
RunApplication()