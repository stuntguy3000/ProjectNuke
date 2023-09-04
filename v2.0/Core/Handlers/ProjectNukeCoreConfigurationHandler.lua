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

local ServiceSelectionPageNumber = 1
local ServiceSelectionPageNumberMaximum = math.ceil(#ProjectNukeCoreServiceHandler:getServicesDatabase() / 5)

local config = nil

function getConfig()
  return config
end

-- Returns true if a valid configuration was found, false if one was created.
function LoadConfiguration()
  if (fs.exists(ConfigurationPath) == true) then
    configTable = ProjectNukeFileUtil.LoadTable(ConfigurationPath)

    if (configTable ~= nil) then
      config = ProjectNukeCoreClasses.Config.new(configTable['encryptionKey'], configTable['enabledApplication'], configTable['enabledService'], configTable['monitorSupport'])
    end
  end

  if (config ~= nil and
    (config.encryptionKey ~= null and
    config.enabledApplication ~= null and
    config.encryptionKey ~= "")) then
    return true;
  end

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
    -- Create GUI
	  ProjectNukeCoreGUIHandler.WriteStatus("Please (optionally) select a service to enable.")

    -- Draw Service Buttons
    DrawServiceSelectionPage(ServiceSelectionPageNumber)

    -- Draw Buttons
    ProjectNukeCoreGUIHandler.AddButton("Continue", nil, "Continue", colours.white, colours.blue, 41, 17, 10, 1, ConfigurationMenuContinue, window)

    if (ServiceSelectionPageNumberMaximum > 1) then
      ProjectNukeCoreGUIHandler.AddButton("ServicePageBack", nil, "<", colours.white, colours.grey, 2, 17, 3, 1, ServicePageBack, window)
      ProjectNukeCoreGUIHandler.AddButton("ServicePageNumber", nil, ServiceSelectionPageNumber, colours.white, colours.lightGrey, 5, 17, 3, 1, nil, window)
      ProjectNukeCoreGUIHandler.AddButton("ServicePageForward", nil, ">", colours.white, colours.grey, 8, 17, 3, 1, ServicePageForward, window)
    end

    ProjectNukeCoreGUIHandler.StartEventListener()
  elseif (pageNumber == 3) then
    -- Create GUI
	  ProjectNukeCoreGUIHandler.WriteStatus("Please enter the shared encryption key.")

    -- Labels
    window.setCursorPos(2,11)
    window.write("Shared Encryption Key (Alphanumeric Chars):")
	  window.setCursorPos(2,14)
    window.write("All applications in Project Nuke use REDNET to")
	  window.setCursorPos(2,15)
    window.write("communicate. Project Nuke implements SHA256")
	  window.setCursorPos(2,16)
    window.write("encryption ensure system security.")

    -- Buttons
    ProjectNukeCoreGUIHandler.AddButton("Continue", nil, "Continue", colours.white, colours.blue, 41, 17, 10, 1, ConfigurationMenuContinue, window)
    ProjectNukeCoreGUIHandler.FocusTextbox(ProjectNukeCoreGUIHandler.AddTextbox("EncryptionKeyInput", 2, 12, 48, window))

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

function DrawServiceSelectionPage(pageNumber)
  -- Index All Services
  servicesDatabase = ProjectNukeCoreServiceHandler:getServicesDatabase()

  -- Attempt to draw up to 5 Services depending on the pageNumber
  baseIndex = (pageNumber - 1) * 5

  for i = 1, 5, 1 do
    service = servicesDatabase[i + baseIndex]

    if (service ~= nil) then
      -- Service entry is valid
      window.setTextColor(colours.grey)
      window.setBackgroundColor(colours.lightGrey)

      -- Draw Label
      window.setCursorPos(8, 10 + i)
      window.write(_G[service]:getDisplayName())

      -- Draw Toggle Button
      ProjectNukeCoreGUIHandler.AddToggleButton(service, "NO", 2, 10 + i, 5, 1, window)
    end
  end
end

-- Advance the Application Page forward
function ApplicationPageForward()
  if (ApplicationSelectionPageNumber < ApplicationSelectionPageNumberMaximum) then
    ApplicationSelectionPageNumber = ApplicationSelectionPageNumber + 1
  end

  drawConfigurationMenu(ConfigurationPageNumber)
end

-- Advance the Application Page backwards
function ApplicationPageBack()
  if (ApplicationSelectionPageNumber > 1) then
    ApplicationSelectionPageNumber = ApplicationSelectionPageNumber - 1

    drawConfigurationMenu(ConfigurationPageNumber)
    return
  end

  ProjectNukeCoreGUIHandler.StartEventListener()
end

-- Advance the Services Page forward
function ServicePageForward()
  if (ServiceSelectionPageNumber < ServiceSelectionPageNumberMaximum) then
    ServiceSelectionPageNumber = ServiceSelectionPageNumber + 1
  end

  drawConfigurationMenu(ConfigurationPageNumber)
end

-- Advance the Services Page backwards
function ServicePageBack()
  if (ServiceSelectionPageNumber > 1) then
    ServiceSelectionPageNumber = ServiceSelectionPageNumber - 1

    drawConfigurationMenu(ConfigurationPageNumber)
    return
  end

  ProjectNukeCoreGUIHandler.StartEventListener()
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
    -- ===== Service Selection Page =====
    -- Inventory the selected buttons
    local toggleButtons = ProjectNukeCoreGUIHandler.GetToggleButtons();
    local enabledServices = {}

    for i, v in pairs(toggleButtons) do
      if (v:getValue() == "YES") then
        table.insert(enabledServices, v:getID())
      end
    end

    if (#enabledServices > 1) then
      -- Throw an error message on the screen, then throw back to the selection menu
      -- If the GUI Handler is working, this should never actually happen... famous last words
      ProjectNukeCoreGUIHandler.DrawPopupMessage({"Error: Please only select one service."}, colours.red, 3)
	    ProjectNukeCoreGUIHandler.StartEventListener()
      return nil
    elseif (#enabledServices == 1) then
      -- Save and continue
      config.enabledService = enabledServices[1]
    elseif (#enabledServices == 0) then
      -- Save and continue
      config.enabledService = nil
    end

    drawConfigurationMenu(3)
  elseif (ConfigurationPageNumber == 3) then
    -- ===== Encryption Key =====
    -- Store value from EncryptionKey textbox
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