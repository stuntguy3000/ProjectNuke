--[[

================================================================================

  ProjectNukeCore-ConfigurationHandler
    Provides computer configuration handling for ProjectNuke core/applications

================================================================================

  Author: stuntguy3000

--]]

local ConfigurationPath = "/ProjectNuke/config.json"

local LoadedConfiguration = {}

-- Config Class
Config = {}
Config.__index = Config

function Config.new(encryptionKey, enabledApplications)
  local self = setmetatable({}, Config)
  
  self.encryptionKey = encryptionKey
  self.enabledApplications = enabledApplications
  
  return self
end

function Config.getName(self)
  return self.applicationName
end

function Config.getEnabledApplications(self)
  return self.enabledApplications
end

function Config.isValid(self)
  return self.enabledApplications
end
-- Config Class End

-- Returns true if a valid configuration was found, false if one was created.
function LoadConfiguration()
  Config = Config or {}
  validConfig = false
  
  if (fs.exists(ConfigurationPath) == true) then
    Config = ProjectNukeCoreFileUtil.LoadTable(ConfigurationPath)
  end
  
  if (Config ~= null and Config:IsValid()) then
    return true;
  end
  
  DefaultApplications = {}
  table.insert(DefaultApplications, "EASC")
  
  Config = Config.new("EncryptionKey", DefaultApplications)
  SaveConfiguration()
  
  return false
end

function SaveConfiguration()
  fs.delete(ConfigurationPath)
  ProjectNukeCoreFileUtil:SaveTable(Config, ConfigurationPath)
end

LoadConfiguration()