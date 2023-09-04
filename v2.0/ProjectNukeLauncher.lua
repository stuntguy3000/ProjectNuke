--[[

================================================================================

  ProjectNukeLauncher
    Used on every computer to download/execute the ProjectNuke Core, which then launches into the ProjectNuke Application.

================================================================================

  Author: stuntguy3000

--]]

term.clear()
download = true

if (not download) then
  shell.run("/ProjectNuke/Core/ProjectNukeCore.lua NODOWNLOAD")
else
  fs.delete("/ProjectNuke/Core/ProjectNukeCore.lua")

  successWget = false
  successLaunch = false

  while (not successWget and not successLaunch) do
    successWget = shell.run("wget https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/ProjectNukeCore.lua /ProjectNuke/Core/ProjectNukeCore.lua")
    successLaunch = shell.run("/ProjectNuke/Core/ProjectNukeCore.lua")
    
    sleep(2)
  end
end