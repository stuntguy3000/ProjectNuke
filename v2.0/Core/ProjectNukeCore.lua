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
    ["CoreClasses"] = "ProjectNukeCoreClasses.lua",
    ["CorePackets"] = "ProjectNukeCorePackets.lua",
}

-- Maps handlers to source locations
local HandlersMap = {
  ["ApplicationHandler"] = "ProjectNukeCoreApplicationHandler.lua",
  ["ConfigurationHandler"] = "ProjectNukeCoreConfigurationHandler.lua",
  ["RednetHandler"] = "ProjectNukeCoreRednetHandler.lua",
}

local UtilMap = {
  ["FileUtil"] = "ProjectNukeCoreFileUtil.lua",
  ["EncryptionUtil"] = "ProjectNukeCoreEncryptionUtil.lua", 
  ["GUIUtil"] = "ProjectNukeCoreGUIUtil.lua",
}

local ClassLoadOrder = {"CoreClasses", "CorePackets"}
local HandlersLoadOrder = {"ApplicationHandler", "ConfigurationHandler", "RednetHandler"}

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

-- Downloads and loads external util
function LoadUtil()
  -- Delete existing core util
  fs.delete(CoreUtilFolderPath)
  
  -- Download the core util to disk
  for utilName, fileName in pairs(UtilMap) do
    fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/Util/" .. fileName
    
    shell.run("wget "..fullURL.." "..CoreUtilFolderPath..fileName)
    os.loadAPI(CoreUtilFolderPath..fileName) 
  end
end

function Run()
  
end

-- Executes ProjectNukeCore
shell.run("clear")
print("===================================================")
print("Starting ProjectNuke Core...")

print("===================================================")
print("Downloading classes...")
DownloadClasses()
print(" ...done!")

print("===================================================")
print("Loading classes...")
LoadClasses()
print(" ...done!")

print("===================================================")
print("Loading util...")
LoadUtil()
print(" ...done!")

print("===================================================")
print("Downloading Handlers...")
DownloadCoreHandlers()
print(" ...done!")

print("===================================================")
print("Loading Handlers...")
LoadCoreHandlers()
print(" ...done!")

print("===================================================")
print("Running ProjectNuke...")
Run()
shell.run("clear")