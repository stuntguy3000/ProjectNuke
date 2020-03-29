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
DOWNLOAD = true
RUN = true

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

local UtilMap = {
  ["FileUtil"] = "ProjectNukeCoreFileUtil.lua",
  ["EncryptionUtil"] = "ProjectNukeCoreEncryptionUtil.lua", 
  ["GUIUtil"] = "ProjectNukeCoreGUIUtil.lua",
}

local ClassLoadOrder = {"CoreClasses", "CorePackets"}
local HandlersLoadOrder = {"ApplicationHandler", "ConfigurationHandler", "RednetHandler", "ServiceHandler"}

-- Core settings
local CoreHandlerFolderPath = "/ProjectNuke/Core/Handlers/"
local CoreUtilFolderPath = "/ProjectNuke/Core/Util/"
local CoreClassFolderPath = "/ProjectNuke/Core/Classes/"

-- Used to download the Handlers
function DownloadCoreHandlers()
  -- Delete existing core Handlers
  fs.delete(CoreHandlerFolderPath)
  
  -- Download the core Handlers to disk
  for Handler, fileName in pairs(HandlersMap) do
    fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/Handlers/" .. fileName
    
    shell.run("wget "..fullURL.." "..CoreHandlerFolderPath..fileName)
  end
end

-- Loads the Handlers
function LoadCoreHandlers()
  for Handler, fileName in pairs(HandlersMap) do
    if (fs.exists(CoreHandlerFolderPath..fileName) == false) then
      error("Handler "..Handler.." could not be found!")
    end
  end
  
  for i, Handler in ipairs(HandlersLoadOrder) do
    print("Loading Handler "..Handler)
    os.loadAPI(CoreHandlerFolderPath..HandlersMap[Handler])  
  end
end

function DownloadClasses()
  -- Delete existing core classes
  fs.delete(CoreClassFolderPath)
  
  -- Download the core classes to disk
  for className, fileName in pairs(ClassMap) do
    fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/Classes/" .. fileName
    
    shell.run("wget "..fullURL.." "..CoreClassFolderPath..fileName)
  end
end

function LoadClasses()
  for Class, fileName in pairs(ClassMap) do
    if (fs.exists(CoreClassFolderPath..fileName) == false) then
      error("Class "..Class.." could not be found!")
    end
  end
  
  for i, Class in ipairs(ClassLoadOrder) do
    print("Loading Class "..Class)
    os.loadAPI(CoreClassFolderPath..ClassMap[Class])  
  end
end

function DownloadUtil()
  -- Delete existing core util
  fs.delete(CoreUtilFolderPath)
  
  -- Download the core classes to disk
  for utilName, fileName in pairs(UtilMap) do
    fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/Util/" .. fileName
    
    shell.run("wget "..fullURL.." "..CoreUtilFolderPath..fileName)
  end
end

-- Downloads and loads external util
function LoadUtil()
  for utilName, fileName in pairs(UtilMap) do
    print(fileName)
    os.loadAPI(CoreUtilFolderPath..fileName) 
    print(fileName)
  end
end


function Run()
  if (RUN) then
    term.clear()
    
    parallel.waitForAny(ProjectNukeCoreApplicationHandler.RunApplications, ProjectNukeCoreServiceHandler.RunServices)
    
    -- In normal operation the application handler will NEVER finish executing. This is assumed so when Parallel finishes, a RunServices service has terminated and needs priority, so now it's time to run the services again.
    ProjectNukeCoreServiceHandler.RunServices()
  end
end

-- Executes ProjectNukeCore
shell.run("clear")
print("===================================================")
print("Starting ProjectNuke Core...")

if (arg[1] == "NODOWNLOAD") then
  DOWNLOAD = false
elseif (arg[1] == "LOADONLY") then
  DOWNLOAD = false
  RUN = false
end

if (DOWNLOAD == true) then
  print("===================================================")
  print("Downloading classes...")
  DownloadClasses()
  print(" ...done!")
end

print("===================================================")
print("Loading classes...")
LoadClasses()
print(" ...done!")

if (DOWNLOAD == true) then
  print("===================================================")
  print("Downloading util...")
  DownloadUtil()
  print(" ...done!")
end

print("===================================================")
print("Loading util...")
LoadUtil()
print(" ...done!")

if (DOWNLOAD == true) then
  print("===================================================")
  print("Downloading Handlers...")
  DownloadCoreHandlers()
  print(" ...done!")
end

print("===================================================")
print("Loading Handlers...")
LoadCoreHandlers()
print(" ...done!")

if (DOWNLOAD == true) then
  print("===================================================")
  print("Downloading Applications/Services...")
  ProjectNukeCoreApplicationHandler.DownloadApplications()
  ProjectNukeCoreServiceHandler.DownloadServices()
  print(" ...done!")
end

ProjectNukeCoreServiceHandler.LoadServices()

print("===================================================")
print("Running ProjectNuke...")
Run()
shell.run("clear")