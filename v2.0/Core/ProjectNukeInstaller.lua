--[[

================================================================================

  ProjectNukeInstaller
    Used on a computer to install a ProjectNuke application.
    
    Install process is as follows:
      1) ProjectNukeCore is downloaded
      2) Application type is selected
      3) Install paramaters are requested

================================================================================

  Author: stuntguy3000

--]]

-- Downloads and executes the ProjectNuke Launcher

fs.delete("/projectnuke.startup")
shell.run("wget https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/Core/ProjectNukeLauncher.lua /projectnuke.startup")

if fs.exists("/projectnuke.startup") == true then
  fs.move("/startup", "/startup.old")
  fs.move("/projectnuke.startup", "/startup")
  
  print("Running launcher...")
  shell.run("/startup")
else
  print("Unable to download and execute ProjectNukeLauncher, please investigate...")
end