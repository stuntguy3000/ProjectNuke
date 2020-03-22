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

function LoadServices()
  fs.delete("/ProjectNuke/Services/")

  -- Download and load services
  for i,service in pairs(Services) do
    fileName = service:getFileName()
    print("Downloading "..service:getName().."("..service:getFileName()..")")
    
    fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Services/"..fileName
    fullPath = ServiceBasePath..fileName
    
    shell.run("wget "..fullURL.." "..fullPath)
    
    -- Load the service
    os.loadAPI(fullPath)  
  end
end

function RunServices()
end

LoadServices()