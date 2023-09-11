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