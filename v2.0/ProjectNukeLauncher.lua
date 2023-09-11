--[[

================================================================================

  ProjectNukeLauncher
    Used on every computer to download/execute the ProjectNuke Core, which then launches into the ProjectNuke Application.

================================================================================

  Author: stuntguy3000

--]]

term.clear()
term.setCursorPos(1, 1)
download = true

if (not download) then
  shell.run("/ProjectNuke/Core/ProjectNukeCore.lua NODOWNLOAD")
else
  fs.delete("/ProjectNuke/Core/ProjectNukeCore.lua")
  success = false

  while (not success) do
    shell.run("wget https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/ProjectNukeCore.lua /ProjectNuke/Core/ProjectNukeCore.lua")
    
    success = shell.run("/ProjectNuke/Core/ProjectNukeCore.lua")

    print("Pausing for 15 seconds...")
    sleep(15)
  end
end