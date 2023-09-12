--[[

================================================================================

  ProjectNukeCoreAuthenticationHandler
    Provides services to allow users to be authenticated

================================================================================

  Author: stuntguy3000

--]]

local authenticatedUser = nil

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
    drawGUI()
end

function drawGUI()
  -- Setup GUI
  authenticationWindow = ProjectNukeCoreGUIHandler.getAuthenticationWindow()
  authenticationWindow.clear()
  
  ProjectNukeCoreGUIHandler.DrawBaseGUI("Please enter your username and password", "Use of this terminal is RESTRICTED.", authenticationWindow)

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
  ProjectNukeCoreGUIHandler.AddButton("login", "Login", "Login", colors.white, colours.green, 41, 17, 7, 1, handleLogin, authenticationWindow)
  ProjectNukeCoreGUIHandler.AddButton("clear", "Clear", "Clear", colors.white, colours.red, 16, 17, 7, 1, handleClear, authenticationWindow)

  ProjectNukeCoreGUIHandler.RefreshTextbox(usernameTextbox)

  -- Bring it together
  authenticationWindow.setVisible(true)
  ProjectNukeCoreGUIHandler.StartEventListener()
end

function handleClear()
  drawGUI()
end

function handleLogin()
  -- Disable GUI
  ProjectNukeCoreGUIHandler.AddButton("login", "Login", "Login", colors.white, colours.grey, 41, 17, 7, 1, handleLogin, authenticationWindow)
  ProjectNukeCoreGUIHandler.AddButton("clear", "Clear", "Clear", colors.white, colours.grey, 16, 17, 7, 1, handleClear, authenticationWindow)
  authenticationWindow.setCursorBlink(false)

  local username = ProjectNukeCoreGUIHandler.GetClickableItemByID("username"):getValue() or ""
  local password = ProjectNukeCoreGUIHandler.GetClickableItemByID("password"):getValue() or ""

  if (username == "" or password == "") then
    -- Validation error
    ProjectNukeCoreGUIHandler.DrawPopupMessage({"Error: Please enter a username and password."}, colors.red, 3)
    drawGUI()
    return
  end

  -- Send Authentication Request
  local requestPacket = ProjectNukeCorePackets.AuthenticationRequestPacket
  requestPacket:setData({username, password})

  ProjectNukeCoreRednetHandler.SendPacket(requestPacket)

  -- Await Reply from Authentication Server
  local responsePacket = ProjectNukeCoreRednetHandler.WaitForPacket(ProjectNukeCorePackets.AuthenticationResponsePacket:getID(), 2)

  if (responsePacket == nil) then
    -- No reply from server
    ProjectNukeCoreGUIHandler.DrawPopupMessage({"Error: No reply from server.", "", "Please try again shortly."}, colors.red, 3)
    drawGUI()
    return
  else
    -- Process Response
  end
end