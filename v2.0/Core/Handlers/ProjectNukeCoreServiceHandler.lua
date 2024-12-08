--[[

================================================================================

  ProjectNukeCoreServiceHandler
    Provides internal service handling to allow the initalization and assignment of services

================================================================================

  Author: stuntguy3000

--]]

local servicesBasePath = "/ProjectNuke/Services/"
local servicesDatabase = { "ProjectNukeServiceINV" }
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
    local fullPath = servicesBasePath..fileName
    
    shell.run("wget "..fullURL.." "..fullPath)
  end
end

-- Load all services into the OS
function tryLoadServices()
  -- Process the Services Database for all Service Classes
  for i, service in ipairs(servicesDatabase) do
    filePath = servicesBasePath .. service .. ".lua"
    print("Trying to load " .. filePath)

    if (fs.exists(filePath)) then
      local loaded = os.loadAPI(filePath)

      if (loaded == false) then
        error("Service " ..  service .. " could not be loaded!")
        return
      end

      print("Service " .. service .. " loaded.")
    end
  end
end

-- Run Services
function tryRunServices()
  -- Identify the services to enable
  for i, service in ipairs(servicesDatabase) do
    -- Enable the service if specified in the configuration
    local configEnabledService = ProjectNukeCoreConfigurationHandler.getConfig().enabledService

    if (configEnabledService ~= nil and configEnabledService == service or true) then
      -- Store as our enabled service
      enabledService = service
      print("Service "..service.." enabled.")

      _G[enabledService]:run()
      return
    end
  end
end

function getServicesDatabase()
  return servicesDatabase
end

tryLoadServices()