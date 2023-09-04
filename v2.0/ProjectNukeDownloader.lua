--[[

================================================================================

  ProjectNukeDownloader
    Used on a computer to download ProjectNuke.
    
    Install process is as follows:
      1) ProjectNukeCore is downloaded
      2) Application type is selected
      3) Install paramaters are requested

================================================================================

  Author: stuntguy3000

--]]

-- Downloads and executes the ProjectNuke Launcher

-- Cleanup old backup files
fs.delete("/projectnuke.startup")
fs.delete("/startup.old")

shell.run("wget https://raw.githubusercontent.com/stuntguy3000/ProjectNuke/master/v2.0/ProjectNukeLauncher.lua /projectnuke.startup")

if fs.exists("/projectnuke.startup") == true then
  if fs.exists("/startup") == true then
    fs.move("/startup", "/startup.old")
  end

  fs.move("/projectnuke.startup", "/startup")

  print(" > Running launcher...")
  shell.run("/startup")
else
  error("Unable to download and execute ProjectNukeLauncher.")
end