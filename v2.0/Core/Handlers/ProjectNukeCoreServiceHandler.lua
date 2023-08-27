--[[

================================================================================

  ProjectNukeCoreServiceHandler
    Provides internal service handling to allow the initalization and assignment of services

================================================================================

  Author: stuntguy3000

--]]

local servicesFolderBasePath = "/ProjectNuke/Services/"
local servicesDatabase = { "ProjectNukeServiceEMRG" }
local enabledService = nil

-- Download Services to Disk
function downloadServices()
  -- Clear local files
  fs.delete("/ProjectNuke/Services/")

  -- Download services to disk
  for i, service in ipairs(servicesDatabase) do
    print("Downloading "..service)
    
    local fileName = service..".lua"
    local fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Services/"..fileName
    local fullPath = servicesFolderBasePath..fileName
    
    shell.run("wget "..fullURL.." "..fullPath)
  end
end

-- Load all services into the OS
function loadServices()
  -- Process the Services Database for all Service Classes
  for i, service in ipairs(servicesDatabase) do
    local loaded = os.loadAPI(servicesFolderBasePath..service..".lua")

    if (loaded == false) then
      error("Service "..service.." could not be loaded!")
      return
    end

    print("Service "..service.." loaded.")
  end
end

-- Run Services
function tryRunServices()
  -- Identify the services to enable
  for i, service in ipairs(servicesDatabase) do
    -- Enable the service if specified in the configuration
    local configEnabledService = ProjectNukeCoreConfigurationHandler.LoadedConfiguration.enabledService

    if (configEnabledService ~= nil and configEnabledService == service) then
      -- Store as our enabled service
      enabledService = service
      print("Service "..service.." enabled.")

      runFunction = _G[enabledService]:run()
      runFunction()
      
      return
    end
  end
end

function getServicesDatabase()
  return servicesDatabase
end

-- Load services as soon as the class is loaded
loadServices()