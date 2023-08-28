--[[

================================================================================

  ProjectNukeCoreApplicationHandler
    Provides internal application handling to allow the initalization and assignment of applications

================================================================================

  Author: stuntguy3000

--]]

local applicationBasePath = "/ProjectNuke/Applications/"
local applicationsDatabase = {
  "ProjectNukeApplicationAUTH",
  "ProjectNukeApplicationEAC",
  "ProjectNukeApplicationRC",
  "ProjectNukeApplicationRM",
  "ProjectNukeApplicationALRT",
  "ProjectNukeApplicationRNET"
}
local enabledApplication = nil

-- Download Applications to Disk
function downloadApplications()
  -- Clear local files
  fs.delete("/ProjectNuke/Applications/")

  for i, application in ipairs(applicationsDatabase) do
    print("Downloading "..application)
    
    local fileName = application..".lua"
    local fullURL = "https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Applications/"..fileName
    local fullPath = applicationBasePath..fileName
    
    shell.run("wget "..fullURL.." "..fullPath)
  end
end

function loadApplications()
  for i, application in ipairs(applicationsDatabase) do
    local loaded = os.loadAPI(applicationBasePath..application..".lua")

    if (loaded == false) then
      error("Application "..application.." could not be loaded!")
      return
    end

    print("Application "..application.." loaded.")
  end
end

-- Run Applications
function tryRunApplications()
  -- Identify the applications to enable
  for i, application in ipairs(applicationsDatabase) do
    -- Enable the application if specified in the configuration
    local configEnabledApplication = ProjectNukeCoreConfigurationHandler.LoadedConfiguration.enabledApplication

    if (configEnabledApplication ~= nil and configEnabledApplication == application) then
      -- Store as our enabled application
      enabledApplication = application
      print("Application "..application.." enabled.")

      runFunction = _G[enabledApplication]:run()
      runFunction()
      
      return
    end
  end
end

function getApplicationsDatabase()
  return applicationsDatabase
end

loadApplications()