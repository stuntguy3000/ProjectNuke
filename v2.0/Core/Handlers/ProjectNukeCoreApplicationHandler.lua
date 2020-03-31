--[[

================================================================================

  ProjectNukeCoreApplicationHandler
    Provides internal application handling to allow the initalization and assignment of applications

================================================================================

  Author: stuntguy3000

--]]

-- http://www.computercraft.info/forums2/index.php?/topic/29696-apifunction-failing/
local ApplicationBasePath = "/ProjectNuke/Applications/"
local RegisteredApplications = {}
local LoadedApplications = {}

function RegisterApplication(applicationName, applicationID, applicationFileName, applicationLaunchFunction)
  -- Test if application exists
  if (GetApplicationByID(applicationID) ~= nil) then
    error("Error: Application "..applicationID.." is already registered.")
  end
  
  newApplication = ProjectNukeCoreClasses.Application.new(applicationName,applicationID, applicationFileName,applicationLaunchFunction)
  table.insert(RegisteredApplications, newApplication)
  
  print("Registered application "..applicationName.." ("..applicationID..").")
end

function GetApplicationByID(applicationID)
  for i,application in pairs(RegisteredApplications) do
    if (application ~= nil and application:getID() == applicationID) then
      return application
    end
  end
  
  return nil
end

function DownloadApplications()
  fs.delete("/ProjectNuke/Applications/")

  -- Download Applications
  for i,application in pairs(RegisteredApplications) do
    fileName = application:getFileName()
    print("Downloading "..application:getName().."("..application:getFileName()..")")
    
    fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Applications/"..fileName
    fullPath = ApplicationBasePath..fileName
    print(fullPath)
    
    shell.run("wget "..fullURL.." "..fullPath)
  end
end

function LoadApplications()
  -- Load all files in ApplicationBasePath
  for i,fileName in pairs(fs.list(ApplicationBasePath)) do
    print("Loading "..fileName)
    os.loadAPI(ApplicationBasePath .. fileName)
  end
  
  -- Register known applications now with run functions
  RegisteredApplications = {}
  RegisterApplication("Access Control Server", "ACS", "ProjectNukeApplicationACS.lua", ProjectNukeApplicationACS.Run)
  RegisterApplication("Emergency Alert Controller", "EAC", "ProjectNukeApplicationEAC.lua",ProjectNukeApplicationEAC.Run)
  RegisterApplication("Reactor Monitor", "RM", "ProjectNukeApplicationRM.lua",ProjectNukeApplicationRM.Run)
  RegisterApplication("Reactor Controller", "RC", "ProjectNukeApplicationRC.lua",ProjectNukeApplicationRC.Run)
  
  -- Add in enabled applications
  for i,applicationName in pairs(ProjectNukeCoreConfigurationHandler.LoadedConfiguration.enabledApplications) do
    application = GetApplicationByID(applicationName)
    
    if (application ~= nil) then
      print("Adding enabled application: "..applicationName)
      table.insert(LoadedApplications, application)
    end
  end
end

function GetRegisteredApplications()
  return RegisteredApplications
end

function RunApplications()
    if (table.getn(LoadedApplications) == 1) then
      -- Run the single registered application
      print("Launching application!")
      RunApplication(LoadedApplications[1])
    else 
      -- Menu, coming later
      print(table.getn(LoadedApplications))
      sleep(10000)
    end
end

function RunApplication(application)
    runFunction = application:getLaunchFunction()
    
    runFunction()
end

  RegisterApplication("Access Control Server", "ACS", "ProjectNukeApplicationACS.lua", nil)
  RegisterApplication("Emergency Alert Controller", "EAC", "ProjectNukeApplicationEAC.lua",nil)
  RegisterApplication("Reactor Monitor", "RM", "ProjectNukeApplicationRM.lua",nil)
  RegisterApplication("Reactor Controller", "RC", "ProjectNukeApplicationRC.lua",nil)