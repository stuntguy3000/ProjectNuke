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
ProjectNukeApplication = {}
ProjectNukeApplication.__index = ProjectNukeApplication

function ProjectNukeApplication.new(applicationName, applicationID, applicationFileName)
  local self = setmetatable({}, ProjectNukeApplication)
  self.applicationName = applicationName
  self.applicationID = applicationID
  self.applicationFileName = applicationFileName
  return self
end

function ProjectNukeApplication.getName(self)
  return self.applicationName
end

function ProjectNukeApplication.getID(self)
  return self.applicationID
end

function ProjectNukeApplication.getFileName(self)
  return self.applicationFileName
end
-- Application Class End

function RegisterApplication(applicationName, applicationID, applicationFileName)
  -- Test if application exists
  if (GetApplicationByID(applicationID) ~= nil) then
    error("Error: Application "..applicationID.." is already registered.")
  end
  
  newApplication = ProjectNukeApplication.new(applicationName,applicationID,applicationFileName)
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
  
  for i,application in pairs(RegisteredApplications) do
    print("Downloading "..application:getName())
    shell.run("wget "..fullURL.." "..CoreFolderPath..fileName)
  end
end

RegisterApplication("Access Control Client", "ACC", "ProjectNukeApplicationACC.lua")
RegisterApplication("Access Control Server", "ACS", "ProjectNukeApplicationACS.lua")
RegisterApplication("Emergency Alert System Client", "EASC", "ProjectNukeApplicationEASC.lua")
RegisterApplication("Emergency Alert System Server", "EASS", "ProjectNukeApplicationEASS.lua")
RegisterApplication("Reactor Monitoring", "RM", "ProjectNukeApplicationRM.lua")

DownloadApplications()