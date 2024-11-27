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
    if (force == true) then
      authenticatedUser = nil
    end

    -- Is a user logged in?
    if (isAuthenticated()) then
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
    ProjectNukeCoreGUIHandler.AddButton("addUser", "Create New User", "Create New User", colors.white, colours.green, 31, 17, 17, 1, handleAdd, authenticationWindow)
    ProjectNukeCoreGUIHandler.AddButton("cancel", "Cancel", "Cancel", colors.white, colours.red, 16, 17, 8, 1, exit, authenticationWindow)
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
    ProjectNukeCoreGUIHandler.DrawPopupMessage({"Error: Please enter a username and password."}, colors.red, 1)
    drawLoginGUI(false)
  elseif (ProjectNukeApplicationAUTH.getUserIndex(username) > 0) then
    -- Validation error
    ProjectNukeCoreGUIHandler.DrawPopupMessage({"Error: This user already exists."}, colors.red, 1)
    drawLoginGUI(false)
  else
    -- Success
    ProjectNukeApplicationAUTH.addUser(username, password)
    ProjectNukeCoreGUIHandler.DrawPopupMessage({"Success: User added to database."}, colors.green, 1)
    exit()
  end
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
  local checksum = ProjectNukeEncryptionUtil.SHA256(username .. password)

  if (username == "" or password == "") then
    -- Validation error
    ProjectNukeCoreGUIHandler.DrawPopupMessage({"Error: Please enter a username and password."}, colors.red, 1)
    drawLoginGUI(true)
    return
  end

  os.sleep(1)

  -- Send Authentication Request
  local requestPacket = ProjectNukeCorePackets.AuthenticationRequestPacket
  requestPacket:setData({username, password})

  -- Authentication Retry Loop
  retry = true
  retryCounter = 1

  while retry == true do
    -- Increment Retry Counter
    retryCounter = retryCounter + 1
    if retryCounter > 6 then
      retry = false
    end

    -- Request Authentication
    ProjectNukeCoreRednetHandler.SendPacket(requestPacket)
    local authenticationResponsePacket = ProjectNukeCoreRednetHandler.WaitForPacket(ProjectNukeCorePackets.AuthenticationResponsePacket, 1)

    -- Test Response Packet for Checksum and Auth
    if (authenticationResponsePacket ~= nil and authenticationResponsePacket:getData() ~= nil) then
      local packetData = authenticationResponsePacket:getData()

      -- Process Successful Auth
      if ((packetData[1] == true) and (packetData[2] == checksum)) then
        ProjectNukeCoreGUIHandler.DrawPopupMessage({"Success", "", "Authenticated as " .. username}, colors.green, 1) 
        authenticatedUser = username
        
        retry = false
        exit()
        return
      end
    end
  end

  -- No reply from server
  ProjectNukeCoreGUIHandler.DrawPopupMessage({"Error: Invalid Credentials or Server Error.", "", "Please try again."}, colors.red, 3)
  drawLoginGUI(true)
end

function exit()
  ProjectNukeCoreGUIHandler.RemoveClickableItemsForWindow(authenticationWindow)
  authenticationWindow.setCursorBlink(false)
  authenticationWindow.setVisible(false)
  
  authenticationWindow.clear()
end