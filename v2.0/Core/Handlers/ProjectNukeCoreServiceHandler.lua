--[[

================================================================================

  ProjectNukeCoreServiceHandler
    Provides internal service handling to allow the initalization and assignment of services

================================================================================

  Author: stuntguy3000

--]]

-- http://www.computercraft.info/forums2/index.php?/topic/29696-apifunction-failing/
local ServiceBasePath = "/ProjectNuke/Services/"
local Services = {
  ["EmergencyService"] = "ProjectNukeEmergencyService.lua",
}

-- Download Services to Disk
function DownloadServices()
  fs.delete("/ProjectNuke/Services/")

  -- Download and load services
  for serviceName,fileName in pairs(Services) do
    print("Downloading "..serviceName.."("..fileName..")")
    
    fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Services/"..fileName
    fullPath = ServiceBasePath..fileName
    
    shell.run("wget "..fullURL.." "..fullPath)
  end
end

-- Load Services from Disk
function LoadServices()
  for serviceName,fileName in pairs(Services) do
    local loaded = os.loadAPI(ServiceBasePath..fileName)

    if (loaded == false) then
      error("Service "..fileName.." could not be loaded!")
    end
  end
end

-- Run Services
function RunServices()
  ProjectNukeEmergencyService.Run()
end