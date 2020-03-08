--[[

================================================================================

  ProjectNukeCore-ApplicationHandlers
    Provides internal application handling to allow the initalization and assignment of applications
    Clients and Servers can 

================================================================================

  Author: stuntguy3000

--]]

local ApplicationBasePath = "/ProjectNuke/Applications/"

local RegisteredApplications = {}
local LoadedApplications = {}

-- Application Class
ProjectNukeApplicationClass = {}
ProjectNukeApplicationClass.__index = ProjectNukeApplicationClass

function ProjectNukeApplicationClass.new(applicationName, applicationID, applicationFileName)
  local self = setmetatable({}, ProjectNukeApplicationClass)
  self.applicationName = applicationName
  self.applicationID = applicationID
  self.applicationFileName = applicationFileName
  return self
end

function ProjectNukeApplicationClass.getName(self)
  return self.applicationName
end

function ProjectNukeApplicationClass.getID(self)
  return self.applicationID
end

function ProjectNukeApplicationClass.getFileName(self)
  return self.applicationFileName
end
-- Application Class End

function RegisterApplication(applicationName, applicationID, applicationFileName)
  -- Test if application exists
  if (GetApplicationByID(applicationID) ~= nil) then
    error("Error: Application "..applicationID.." is already registered.")
  end
  
  newApplication = ProjectNukeApplicationClass.new(applicationName,applicationID,applicationFileName)
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
    
    fullUrl = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Applications/"..fileName
    
    shell.run("wget "..fullURL.." "..CoreFolderPath..fileName)
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