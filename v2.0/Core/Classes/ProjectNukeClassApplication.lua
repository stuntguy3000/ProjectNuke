-- Application Class
ProjectNukeClassApplication = {}
ProjectNukeClassApplication.__index = ProjectNukeClassApplication

function ProjectNukeClassApplication.new(applicationName, applicationID, applicationFileName)
  local self = setmetatable({}, ProjectNukeClassApplication)
  self.applicationName = applicationName
  self.applicationID = applicationID
  self.applicationFileName = applicationFileName
  return self
end

function ProjectNukeClassApplication.getName(self)
  return self.applicationName
end

function ProjectNukeClassApplication.getID(self)
  return self.applicationID
end

function ProjectNukeClassApplication.getFileName(self)
  return self.applicationFileName
end
-- Application Class End