--[[

================================================================================

  ProjectNukeCore-ApplicationHandlers
    Provides internal application handling to allow the initalization and assignment of applications
    Clients and Servers can 

================================================================================

  Author: stuntguy3000

--]]

-- http://www.computercraft.info/forums2/index.php?/topic/29696-apifunction-failing/
local ApplicationBasePath = "/ProjectNuke/Applications/"
local RegisteredApplications = {}
local LoadedApplications = {}

function RegisterApplication(applicationName, applicationID, applicationFileName)
  -- Test if application exists
  if (GetApplicationByID(applicationID) ~= nil) then
    error("Error: Application "..applicationID.." is already registered.")
  end
  
  newApplication = ProjectNukeClassApplication.new(applicationName,applicationID,applicationFileName)
  table.insert(RegisteredApplications, newApplication)
  
  print("Registered application "..applicationName.." ("..applicationID..").")
end

function GetApplicationByID(applicationID)
  for i,application in pairs(RegisteredApplications) do
    if (application ~= nil and application.id == applicationID) then
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

function GetRegisteredApplications()
  return RegisteredApplications
end

RegisterApplication("Access Control Client", "ACC", "ProjectNukeApplicationACC.lua")
RegisterApplication("Access Control Server", "ACS", "ProjectNukeApplicationACS.lua")
RegisterApplication("Emergency Alert System Client", "EASC", "ProjectNukeApplicationEASC.lua")
RegisterApplication("Emergency Alert System Server", "EASS", "ProjectNukeApplicationEASS.lua")
RegisterApplication("Reactor Monitoring", "RM", "ProjectNukeApplicationRM.lua")

DownloadApplications()