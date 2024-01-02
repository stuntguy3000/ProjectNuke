--[[

================================================================================

  ProjectNukeCoreConfigurationHandler
    Provides computer configuration handling for ProjectNuke core/applications

================================================================================

  Author: stuntguy3000

--]]

local ConfigurationPath = "/ProjectNuke/config"
local ConfigurationPageNumber = 0

local ApplicationSelectionPageNumber = 1
local ApplicationSelectionPageNumberMaximum = math.ceil(#ProjectNukeCoreApplicationHandler:getApplicationsDatabase() / 5)

local config = nil

function getConfig()
  return config
end

-- Returns true if a valid configuration was found, false if one was created.
function LoadConfiguration()
  -- Attempt to load an existing configuration file
  if (fs.exists(ConfigurationPath) == true) then
    configTable = ProjectNukeFileUtil.LoadTable(ConfigurationPath)

    if (configTable ~= nil) then
      config = ProjectNukeCoreClasses.Config.new(configTable['encryptionKey'], configTable['enabledApplication'], configTable['plantName'], configTable['monitorSupport'])
    end
  end

  -- If loaded, validate the config file and it's fields
  if (config ~= nil and config.enabledApplication ~= nil and
    config.plantName ~= nil and config.plantName ~= "" and
    config.encryptionKey ~= nil and config.encryptionKey ~= "") then
    return true;
  end

  -- Invalidate config and start again.
  config = ProjectNukeCoreClasses.Config.new("", {})
  SaveConfiguration()
  return false
end

function SaveConfiguration()
  fs.delete(ConfigurationPath)
  ProjectNukeFileUtil.SaveTable(config, ConfigurationPath)
end

function drawConfigurationMenu(pageNumber)
  ConfigurationPageNumber = pageNumber

  -- Init GUI
  window = ProjectNukeCoreGUIHandler.getMainWindow()
  ProjectNukeCoreGUIHandler.clearWindow(window)

  ProjectNukeCoreGUIHandler.DrawBaseGUI("Project Nuke Configuration (Step " .. ConfigurationPageNumber .. "/5)", "Welcome to Project Nuke!", window)

  if (pageNumber == 1) then
    -- Create GUI
    ProjectNukeCoreGUIHandler.WriteStatus("Please select an application to install.", window)

    -- Draw Application Buttons
    DrawApplicationSelectionPage(ApplicationSelectionPageNumber)

    -- Draw Buttons
    ProjectNukeCoreGUIHandler.AddButton("Continue", nil, "Continue", colours.white, colours.blue, 41, 17, 10, 1, ConfigurationMenuContinue, window)

    if (ApplicationSelectionPageNumberMaximum > 1) then
      ProjectNukeCoreGUIHandler.AddButton("AppPageBack", nil, "<", colours.white, colours.grey, 2, 17, 3, 1, ApplicationPageBack, window)
      ProjectNukeCoreGUIHandler.AddButton("AppPageNumber", nil, ApplicationSelectionPageNumber, colours.white, colours.lightGrey, 5, 17, 3, 1, nil, window)
      ProjectNukeCoreGUIHandler.AddButton("AppPageForward", nil, ">", colours.white, colours.grey, 8, 17, 3, 1, ApplicationPageForward, window)
    end

    ProjectNukeCoreGUIHandler.StartEventListener()
  elseif (pageNumber == 2) then
    -- Plant Name
	  ProjectNukeCoreGUIHandler.WriteStatus("Please enter the name of your power plant.")

    window.setCursorPos(2,11)
    window.write("Power Plant Name:")
	  window.setCursorPos(2,14)
    window.write("ProjectNuke computers only communicate")
	  window.setCursorPos(2,15)
    window.write("to those in the same power plant. As such,")
	  window.setCursorPos(2,16)
    window.write("please use the same name for all computers.")

    -- Buttons
    ProjectNukeCoreGUIHandler.AddButton("Continue", nil, "Continue", colours.white, colours.blue, 41, 17, 10, 1, ConfigurationMenuContinue, window)
    ProjectNukeCoreGUIHandler.RefreshTextbox(ProjectNukeCoreGUIHandler.AddTextbox("PlantNameInput", 2, 12, 49, window))

    ProjectNukeCoreGUIHandler.StartEventListener()
  elseif (pageNumber == 3) then
    -- Create GUI
	  ProjectNukeCoreGUIHandler.WriteStatus("Please enter the shared encryption key.")

    -- Labels
    window.setCursorPos(2,11)
    window.write("Shared Encryption Key (Alphanumeric Chars):")
	  window.setCursorPos(2,14)
    window.write("All applications in ProjectNuke use REDNET to")
	  window.setCursorPos(2,15)
    window.write("communicate. ProjectNuke implements SHA256")
	  window.setCursorPos(2,16)
    window.write("encryption ensure system security.")

    -- Buttons
    ProjectNukeCoreGUIHandler.AddButton("Continue", nil, "Continue", colours.white, colours.blue, 41, 17, 10, 1, ConfigurationMenuContinue, window)
    ProjectNukeCoreGUIHandler.RefreshTextbox(ProjectNukeCoreGUIHandler.AddTextbox("EncryptionKeyInput", 2, 12, 49, window))

    ProjectNukeCoreGUIHandler.StartEventListener()
  elseif (pageNumber == 4) then
    -- Create GUI
	  ProjectNukeCoreGUIHandler.WriteStatus("Specify any optional settings.")

    -- Labels
    window.setCursorPos(8,11)
    window.write("Application External Monitor Support")

    -- Buttons
    ProjectNukeCoreGUIHandler.AddToggleButton("MonitorSupport", "YES", 2, 11, 5, 1, window)
    ProjectNukeCoreGUIHandler.AddButton("Continue", nil, "Continue", colours.white, colours.blue, 41, 17, 10, 1, ConfigurationMenuContinue, window)

    ProjectNukeCoreGUIHandler.StartEventListener()
  elseif (pageNumber == 5) then
    SaveConfiguration()

    -- Create GUI
	  ProjectNukeCoreGUIHandler.WriteStatus("Installation completed.")

    -- Labels
    window.setCursorPos(2,11)
    window.setTextColour(colours.white)
    window.write("Thanks for installing Project Nuke!")
    window.setTextColour(colours.grey)
	  window.setCursorPos(2,13)
    window.write("Please setup all your other computers with various")
	  window.setCursorPos(2,14)
    window.write("Project Nuke applications and begin generating")
	  window.setCursorPos(2,15)
    window.write("safe, clean and efficient nuclear power!")

	  window.setCursorPos(2,17)
    window.setTextColor(colours.black)
    window.write("To begin, click Finish.")

    -- Buttons
    ProjectNukeCoreGUIHandler.AddButton("Finish", nil, "Finish", colours.white, colours.green, 41, 17, 10, 1, ConfigurationMenuContinue, window)

    ProjectNukeCoreGUIHandler.StartEventListener()
  end
end

function DrawApplicationSelectionPage(pageNumber)
  -- Index All Applications
  applicationsDatabase = ProjectNukeCoreApplicationHandler:getApplicationsDatabase()

  -- Attempt to draw up to 5 Applications depending on the pageNumber
  baseIndex = (pageNumber - 1) * 5

  for i = 1, 5, 1 do
    application = applicationsDatabase[i + baseIndex]

    if (application ~= nil) then
      -- Application entry is valid
      window.setTextColor(colours.grey)
      window.setBackgroundColor(colours.lightGrey)

      -- Draw Label
      window.setCursorPos(8, 10 + i)
      print(application)
      window.write(_G[application]:getDisplayName())

      -- Draw Toggle Button
      ProjectNukeCoreGUIHandler.AddToggleButton(application, "NO", 2, 10 + i, 5, 1, window)
    end
  end
end

-- Advance the Application Page forward
function ApplicationPageForward()
  if (ApplicationSelectionPageNumber < ApplicationSelectionPageNumberMaximum) then
    ApplicationSelectionPageNumber = ApplicationSelectionPageNumber + 1
    drawConfigurationMenu(ConfigurationPageNumber)
  else
    ProjectNukeCoreGUIHandler.StartEventListener()
  end
end

-- Advance the Application Page backwards
function ApplicationPageBack()
  if (ApplicationSelectionPageNumber > 1) then
    ApplicationSelectionPageNumber = ApplicationSelectionPageNumber - 1
    drawConfigurationMenu(ConfigurationPageNumber)
  else
    ProjectNukeCoreGUIHandler.StartEventListener()
  end
end

-- Configuration menu page continue
function ConfigurationMenuContinue()
  if (ConfigurationPageNumber == 1) then
    -- ===== Application Selection Page =====
    -- Inventory the selected buttons
    local toggleButtons = ProjectNukeCoreGUIHandler.GetToggleButtons();
    local enabledApplications = {}

    for i, v in pairs(toggleButtons) do
      if (v:getValue() == "YES") then
        table.insert(enabledApplications, v:getID())
      end
    end

    if (#enabledApplications == 1) then
      -- Save and continue
      config.enabledApplication = enabledApplications[1]
    else
      -- Throw an error message on the screen, then throw back to the selection menu
      ProjectNukeCoreGUIHandler.DrawPopupMessage({"Error: Please select an application."}, colours.red, 3)
	    ProjectNukeCoreGUIHandler.StartEventListener()
      return nil
    end

    drawConfigurationMenu(2)
  elseif (ConfigurationPageNumber == 2) then
    -- ===== Plant Name =====
    local plantNameTextbox = ProjectNukeCoreGUIHandler.GetClickableItemByID("PlantNameInput");
    local plantName = plantNameTextbox:getValue()

    if (plantName == nil or plantName == "") then
      ProjectNukeCoreGUIHandler.DrawPopupMessage({"Error: Please enter a valid Plant Name."}, colours.red, 3)
      ProjectNukeCoreGUIHandler.StartEventListener()
      return nil
    end

    config.plantName = plantName

    drawConfigurationMenu(3)
  elseif (ConfigurationPageNumber == 3) then
    -- ===== Encryption Key =====
    local encryptionKeyTextbox = ProjectNukeCoreGUIHandler.GetClickableItemByID("EncryptionKeyInput");
    local encryptionKey = encryptionKeyTextbox:getValue()

	  if (encryptionKey == nil or encryptionKey == "" or encryptionKey:match("%W")) then
	    ProjectNukeCoreGUIHandler.DrawPopupMessage({"Error: Please enter a valid Encryption Key."}, colours.red, 3)
	    ProjectNukeCoreGUIHandler.StartEventListener()
		  return nil
	  end

    config.encryptionKey = encryptionKey

    drawConfigurationMenu(4)
  elseif (ConfigurationPageNumber == 4) then
    -- ===== Monitor Support =====
    monitorSupportButton = ProjectNukeCoreGUIHandler.GetClickableItemByID("MonitorSupport");

    if (monitorSupportButton:getValue() == "YES") then
      config.monitorSupport = true
    else
      config.monitorSupport = false
    end

    drawConfigurationMenu(5)
  elseif (ConfigurationPageNumber == 5) then
    os.reboot()
  end
end