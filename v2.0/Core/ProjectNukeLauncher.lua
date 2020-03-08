--[[

================================================================================

  ProjectNukeLauncher
    Used on every computer to download/execute the ProjectNuke Core, which then launches into the ProjectNuke Application.

================================================================================

  Author: stuntguy3000

--]]
function DownloadAndExecuteCore()
  shell.run("https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/ProjectNukeCore.lua")
end

DownloadAndExecuteCore()