--[[

================================================================================

  ProjectNukeLauncher
    Used on every computer to download/execute the ProjectNuke Core, which then launches into the ProjectNuke Application.

================================================================================

  Author: stuntguy3000

--]]

NODOWNLOAD = true
LOADONLY = false

function DownloadAndExecuteCore()
  print(" > Downloading core...")
  
  if (NODOWNLOAD) then
    shell.run("/ProjectNuke/Core/ProjectNukeCore.lua NODOWNLOAD")
  elseif (LOADONLY) then
    fs.delete("/ProjectNuke/Core/ProjectNukeCore.lua")
    shell.run("wget https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/ProjectNukeCore.lua /ProjectNuke/Core/ProjectNukeCore.lua")
    shell.run("/ProjectNuke/Core/ProjectNukeCore.lua LOADONLY")
  else
    fs.delete("/ProjectNuke/Core/ProjectNukeCore.lua")
    shell.run("wget https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/ProjectNukeCore.lua /ProjectNuke/Core/ProjectNukeCore.lua")
    shell.run("/ProjectNuke/Core/ProjectNukeCore.lua")
  end
end

DownloadAndExecuteCore()