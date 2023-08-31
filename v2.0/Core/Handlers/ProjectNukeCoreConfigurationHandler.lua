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

LoadedConfiguration = nil

-- Returns true if a valid configuration was found, false if one was created.
function LoadConfiguration()
  if (fs.exists(ConfigurationPath) == true) then
    configTable = ProjectNukeCoreFileUtil.LoadTable(ConfigurationPath)

    if (configTable ~= nil) then
      LoadedConfiguration = ProjectNukeCoreClasses.Config.new(configTable['encryptionKey'], configTable['enabledApplication'], configTable['enabledService'])
    end
  end

  if (LoadedConfiguration ~= nil and
    (LoadedConfiguration.encryptionKey ~= null and
    LoadedConfiguration.enabledApplication ~= null and
    LoadedConfiguration.encryptionKey ~= "")) then
    return true;
  end

  LoadedConfiguration = ProjectNukeCoreClasses.Config.new("", {})
  SaveConfiguration()

  return false
end

function SaveConfiguration()
  fs.delete(ConfigurationPath)

  ProjectNukeCoreFileUtil.SaveTable(LoadedConfiguration, ConfigurationPath)
end

function DrawConfigurationMenu(pageNumber)
  -- Init GUI
  ProjectNukeCoreGUIUtil.clearGUI()

  window = ProjectNukeCoreGUIUtil.getMainWindow()

  if (pageNumber == 1) then
    ConfigurationPageNumber = 1

    -- Create GUI
    ProjectNukeCoreGUIUtil.DrawBaseGUI("Project Nuke Configuration (Step 1/4)", "Welcome to Project Nuke!")
	  ProjectNukeCoreGUIUtil.DrawStatus("Please select an application to install.")

    -- Draw Application Buttons
    DrawApplicationSelectionPage(ApplicationSelectionPageNumber)

    -- Draw Buttons
    ProjectNukeCoreGUIUtil.AddButton("Continue", nil, "Continue", colours.white, colours.blue, 41, 17, 10, 1, ConfigurationMenuContinue)

    if (ApplicationSelectionPageNumberMaximum > 1) then
      ProjectNukeCoreGUIUtil.AddButton("AppPageBack", nil, "<", colours.white, colours.grey, 2, 17, 3, 1, ApplicationPageBack)
      ProjectNukeCoreGUIUtil.AddButton("AppPageNumber", nil, ApplicationSelectionPageNumber, colours.white, colours.lightGrey, 5, 17, 3, 1, nil)
      ProjectNukeCoreGUIUtil.AddButton("AppPageForward", nil, ">", colours.white, colours.grey, 8, 17, 3, 1, ApplicationPageForward)
    end

    ProjectNukeCoreGUIUtil.StartEventListener()
  elseif (pageNumber == 2) then
    ConfigurationPageNumber = 2

    -- Create GUI
    ProjectNukeCoreGUIUtil.DrawBaseGUI("Project Nuke Configuration (Step 2/4)", "Welcome to Project Nuke!")
	  ProjectNukeCoreGUIUtil.DrawStatus("Please (optionally) select a service to enable.")

    -- Draw Service Buttons
    DrawServiceSelectionPage(ServiceSelectionPageNumber)

    -- Draw Buttons
    ProjectNukeCoreGUIUtil.AddButton("Continue", nil, "Continue", colours.white, colours.blue, 41, 17, 10, 1, ConfigurationMenuContinue)

    if (ServiceSelectionPageNumberMaximum > 1) then
      ProjectNukeCoreGUIUtil.AddButton("ServicePageBack", nil, "<", colours.white, colours.grey, 2, 17, 3, 1, ServicePageBack)
      ProjectNukeCoreGUIUtil.AddButton("ServicePageNumber", nil, ServiceSelectionPageNumber, colours.white, colours.lightGrey, 5, 17, 3, 1, nil)
      ProjectNukeCoreGUIUtil.AddButton("ServicePageForward", nil, ">", colours.white, colours.grey, 8, 17, 3, 1, ServicePageForward)
    end

    ProjectNukeCoreGUIUtil.StartEventListener()
  elseif (pageNumber == 3) then
    ConfigurationPageNumber = 3

    -- Create GUI
    ProjectNukeCoreGUIUtil.DrawBaseGUI("Project Nuke Configuration (Step 3/4)", "Welcome to Project Nuke!")
	  ProjectNukeCoreGUIUtil.DrawStatus("Please enter the shared encryption key.")

    -- Labels
    window.setCursorPos(2,11)
    window.write("Shared Encryption Key (Alphanumeric Chars ):")
	  window.setCursorPos(2,14)
    window.write("All applications in Project Nuke use REDNET to")
	  window.setCursorPos(2,15)
    window.write("communicate. Project Nuke implements SHA256")
	  window.setCursorPos(2,16)
    window.write("encryption ensure system security.")

    -- Buttons
    ProjectNukeCoreGUIUtil.AddButton("Continue", nil, "Continue", colours.white, colours.blue, 41, 17, 10, 1, ConfigurationMenuContinue)
    ProjectNukeCoreGUIUtil.UpdateTextbox(ProjectNukeCoreGUIUtil.AddTextbox("EncryptionKeyInput", 2, 12, 48))

    ProjectNukeCoreGUIUtil.StartEventListener()
  elseif (pageNumber == 4) then
    ConfigurationPageNumber = 4

    -- Create GUI
    ProjectNukeCoreGUIUtil.DrawBaseGUI("Project Nuke Configuration (Step 4/4)", "Welcome to Project Nuke!")
	  ProjectNukeCoreGUIUtil.DrawStatus("Installation completed.")

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
    window.write("To begin, click Finish.")

    -- Buttons
    ProjectNukeCoreGUIUtil.AddButton("Finish", nil, "Finish", colours.white, colours.green, 41, 17, 10, 1, ConfigurationMenuContinue)

    ProjectNukeCoreGUIUtil.StartEventListener()
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
      ProjectNukeCoreGUIUtil.AddToggleButton(application, "NO", 2, 10 + i, 5, 1)
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
      ProjectNukeCoreGUIUtil.AddToggleButton(service, "NO", 2, 10 + i, 5, 1)
    end
  end
end

-- Advance the Application Page forward
function ApplicationPageForward()
  if (ApplicationSelectionPageNumber < ApplicationSelectionPageNumberMaximum) then
    ApplicationSelectionPageNumber = ApplicationSelectionPageNumber + 1
  end

  DrawConfigurationMenu(ConfigurationPageNumber)
end

-- Advance the Application Page backwards
function ApplicationPageBack()
  if (ApplicationSelectionPageNumber > 1) then
    ApplicationSelectionPageNumber = ApplicationSelectionPageNumber - 1

    DrawConfigurationMenu(ConfigurationPageNumber)
    return
  end

  ProjectNukeCoreGUIUtil.StartEventListener()
end

-- Advance the Services Page forward
function ServicePageForward()
  if (ServiceSelectionPageNumber < ServiceSelectionPageNumberMaximum) then
    ServiceSelectionPageNumber = ServiceSelectionPageNumber + 1
  end

  DrawConfigurationMenu(ConfigurationPageNumber)
end

-- Advance the Services Page backwards
function ServicePageBack()
  if (ServiceSelectionPageNumber > 1) then
    ServiceSelectionPageNumber = ServiceSelectionPageNumber - 1

    DrawConfigurationMenu(ConfigurationPageNumber)
    return
  end

  ProjectNukeCoreGUIUtil.StartEventListener()
end

-- Configuration menu page continue
function ConfigurationMenuContinue()
  if (ConfigurationPageNumber == 1) then
    -- ===== Application Selection Page =====
    -- Inventory the selected buttons
    ToggleButtons = ProjectNukeCoreGUIUtil.GetToggleButtons();
    EnabledApplications = {}

    for i, v in pairs(ToggleButtons) do
      if (v:getValue() == "YES") then
        table.insert(EnabledApplications, v:getID())
      end
    end

    if (#EnabledApplications > 1) then
      -- Throw an error message on the screen, then throw back to the selection menu
      -- If the GUI Handler is working, this should never actually happen... famous last words
      ProjectNukeCoreGUIUtil.DrawErrorMessages({[10] = "Error: Please only select one application."}, 3)
	    ProjectNukeCoreGUIUtil.StartEventListener()
      return nil
    elseif (#EnabledApplications == 1) then
      -- Save and continue
      LoadedConfiguration.enabledApplication = EnabledApplications[1]
      SaveConfiguration()
    end

    DrawConfigurationMenu(2)
  elseif (ConfigurationPageNumber == 2) then
    -- ===== Service Selection Page =====
    -- Inventory the selected buttons
    ToggleButtons = ProjectNukeCoreGUIUtil.GetToggleButtons();
    EnabledServices = {}

    for i, v in pairs(ToggleButtons) do
      if (v:getValue() == "YES") then
        table.insert(EnabledServices, v:getID())
      end
    end

    if (#EnabledServices > 1) then
      -- Throw an error message on the screen, then throw back to the selection menu
      -- If the GUI Handler is working, this should never actually happen... famous last words
      ProjectNukeCoreGUIUtil.DrawErrorMessages({[10] = "Error: Please only select one service."}, 3)
	    ProjectNukeCoreGUIUtil.StartEventListener()
      return nil
    elseif (#EnabledServices == 1) then
      -- Save and continue
      LoadedConfiguration.enabledService = EnabledServices[1]
      SaveConfiguration()
    end

    DrawConfigurationMenu(3)
  elseif (ConfigurationPageNumber == 3) then
    -- ===== Encryption Key =====
    -- Store value from EncryptionKey textbox
    EncryptionKeyTextbox = ProjectNukeCoreGUIUtil.GetClickableItemByID("EncryptionKeyInput");
    EncryptionKey = EncryptionKeyTextbox:getValue()

	  if (EncryptionKey == nil or EncryptionKey == "" or EncryptionKey:match("%W")) then
	    ProjectNukeCoreGUIUtil.DrawErrorMessages({[10] = "Error: Please enter a valid Encryption Key."}, 3)
	    ProjectNukeCoreGUIUtil.StartEventListener()
		  return nil
	  end

    LoadedConfiguration.encryptionKey = EncryptionKey
    SaveConfiguration()

    DrawConfigurationMenu(4)
  end
end

-- Attempt to load the configuration, but if one is not detected, run the installer GUI
if (LoadConfiguration() == false) then
  print("New configuration detected, launching installer.")

  DrawConfigurationMenu(1)
end