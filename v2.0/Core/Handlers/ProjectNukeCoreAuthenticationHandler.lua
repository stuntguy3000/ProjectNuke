--[[

================================================================================

  ProjectNukeCoreAuthenticationHandler
    Provides services to allow users to be authenticated

================================================================================

  Author: stuntguy3000

--]]

local authenticatedUser = nil


--[[
================================================================================
  Authentication
================================================================================
]]--
function isAuthenticated()
  return authenticatedUser ~= nil
end

function getAuthenticatedUser()
  return authenticatedUser
end

function requestAuthentication(force)
    -- Force reauthentication if a user is logged in
    if (force) then
        authenticatedUser = nil
    end

    -- Is a user logged in?
    if (authenticatedUser) then
        return true
    end

    -- Request Authentication
    drawLoginGUI(true)
end

--[[
================================================================================
  Login GUI
================================================================================
]]--

function drawLoginGUI(doAuthenticate)
  -- Setup GUI
  authenticationWindow = ProjectNukeCoreGUIHandler.getAuthenticationWindow()
  authenticationWindow.clear()
  
  ProjectNukeCoreGUIHandler.DrawBaseGUI("Please enter a username and password", "Use of this terminal is RESTRICTED.", authenticationWindow)

  -- Labels
  authenticationWindow.setTextColor(colours.black)
  authenticationWindow.setBackgroundColor(colours.lightGrey)

  authenticationWindow.setCursorPos(5, 12)
  authenticationWindow.write("Username:")
  authenticationWindow.setCursorPos(5, 14)
  authenticationWindow.write("Password:")

  -- Textboxes
  usernameTextbox = ProjectNukeCoreGUIHandler.AddTextbox("username", 16, 12, 32, authenticationWindow)
  passwordTextbox = ProjectNukeCoreGUIHandler.AddTextbox("password", 16, 14, 32, authenticationWindow)

  -- Buttons
  if doAuthenticate then
    -- Authentication Form
    ProjectNukeCoreGUIHandler.AddButton("login", "Login", "Login", colors.white, colours.green, 41, 17, 7, 1, handleLogin, authenticationWindow)
    ProjectNukeCoreGUIHandler.AddButton("clear", "Clear", "Clear", colors.white, colours.red, 16, 17, 7, 1, handleClear, authenticationWindow)
  else
    -- Add User Form
    ProjectNukeCoreGUIHandler.AddButton("addUser", "Add", "Add", colors.white, colours.green, 43, 17, 5, 1, handleAdd, authenticationWindow)
    ProjectNukeCoreGUIHandler.AddButton("close", "Close", "Close", colors.white, colours.red, 16, 17, 7, 1, handleClose, authenticationWindow)
  end
  
  ProjectNukeCoreGUIHandler.RefreshTextbox(usernameTextbox)

  -- Bring it together
  authenticationWindow.setVisible(true)
  ProjectNukeCoreGUIHandler.StartEventListener()
end

-- Add the user to the user database
function handleAdd()
  local username = ProjectNukeCoreGUIHandler.GetClickableItemByID("username"):getValue() or ""
  local password = ProjectNukeCoreGUIHandler.GetClickableItemByID("password"):getValue() or ""

  if (username == "" or password == "") then
    -- Validation error
    ProjectNukeCoreGUIHandler.DrawPopupMessage({"Error: Please enter a username and password."}, colors.red, 3)
    drawLoginGUI(false)
  elseif (ProjectNukeApplicationAUTH.getUserIndex(username) > 0) then
    -- Validation error
    ProjectNukeCoreGUIHandler.DrawPopupMessage({"Error: This user already exists."}, colors.red, 3)
    drawLoginGUI(false)
  else
    -- Success
    ProjectNukeApplicationAUTH.addUser(username, password)
    ProjectNukeCoreGUIHandler.DrawPopupMessage({"Success: User added to database."}, colors.green, 3)
  end
end

function handleClose()
  -- Nothing to do here!
end

function handleClear()
  drawLoginGUI(true)
end

function handleLogin()
  -- Disable GUI
  ProjectNukeCoreGUIHandler.AddButton("login", "Login", "Login", colors.white, colours.grey, 41, 17, 7, 1, nil, authenticationWindow)
  ProjectNukeCoreGUIHandler.AddButton("clear", "Clear", "Clear", colors.white, colours.grey, 16, 17, 7, 1, nil, authenticationWindow)
  authenticationWindow.setCursorBlink(false)

  local username = ProjectNukeCoreGUIHandler.GetClickableItemByID("username"):getValue() or ""
  local password = ProjectNukeCoreGUIHandler.GetClickableItemByID("password"):getValue() or ""

  if (username == "" or password == "") then
    -- Validation error
    ProjectNukeCoreGUIHandler.DrawPopupMessage({"Error: Please enter a username and password."}, colors.red, 3)
    drawLoginGUI(true)
    return
  end

  os.sleep(1)

  -- Send Authentication Request
  local requestPacket = ProjectNukeCorePackets.AuthenticationRequestPacket
  requestPacket:setData({username, password})
  ProjectNukeCoreRednetHandler.SendPacket(requestPacket)

  -- Todo:
  --     Checksums, reliable packet transmission/receiving, robustness.

  -- Await Reply from Authentication Server
  local packet = ProjectNukeCoreRednetHandler.WaitForPacket(ProjectNukeCorePackets.AuthenticationResponsePacket, 2)

  if (packet == nil) then
    -- No reply from server
    ProjectNukeCoreGUIHandler.DrawPopupMessage({"Error: No reply from server.", "", "Please try again shortly."}, colors.red, 3)
    drawLoginGUI(true)
  else
    -- Process Response
    ProjectNukeCoreGUIHandler.DrawPopupMessage({"Success", "", "Success."}, colors.green, 3)
  end
end