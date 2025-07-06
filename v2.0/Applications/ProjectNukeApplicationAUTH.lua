--[[

================================================================================

  ProjectNukeApplicarionAUTH
    Application: Authentication Server

================================================================================

  Author: stuntguy3000

--]]
local usersPageNumber = 1
local usersPageNumberMaximum = 1
local usersPerPage = 4

userDatabase = {
  {"User1", "Password"}, {"User2", "Password"}, {"User3", "Password"}, {"User4", "Password"}, {"User5", "Password"}, {"User6", "Password"}, {"User7", "Password"}, {"User8", "Password"}, {"User9", "Password"}, {"User10", "Password"}, {"User11", "Password"}, {"User12", "Password"}
}
local userDatabasePath = "/ProjectNuke/users"

function getDisplayName()
  return "Authentication Server"
end

function run()
  -- Init GUI
  ProjectNukeCoreGUIHandler.initGUI(false)

  -- Load User Database
  if (fs.exists(userDatabasePath) == true) then
    userDatabase = ProjectNukeFileUtil.LoadTable(userDatabasePath)
  end

  -- Run Server and GUI
  guiInit()
  userTableInit()
  
  while true do
    parallel.waitForAny(runAuthServer, ProjectNukeCoreGUIHandler.StartEventListener)
  end
end

--[[
================================================================================
  GUI & Pagination
================================================================================
]]--

function guiInit()
  local window = ProjectNukeCoreGUIHandler.getMainWindow()

  -- Prepare Graphics
  ProjectNukeCoreGUIHandler.DrawBaseGUI(getDisplayName(), nil, window)

  ProjectNukeCoreGUIHandler.WriteStatus("Authentication Server Running...")
end

function userTableInit()
  local window = ProjectNukeCoreGUIHandler.getMainWindow()

  window.setCursorPos(2, 8)
  window.setTextColor(colours.white)
  window.setBackgroundColor(colours.lightGrey)
  window.write("                                                  ")
  
  window.setCursorPos(2, 8)
  window.write("User Count: " .. #userDatabase)

  -- Render Menu
  local userListMenu = ProjectNukeCoreClassesGUI.Menu.new("UserList", window, 2, 10, 23, 6, "Add User", colours.green, userAddButton)
  for _, user in ipairs(userDatabase) do
    local removeUserButton = ProjectNukeCoreClassesGUI.MenuItemButton.new("Delete", colours.red, user[1], userRemoveButton)
    local changePasswordButton = ProjectNukeCoreClassesGUI.MenuItemButton.new("Set Pwd", colours.blue, user[1], userChangePasswordButton)
    
    -- Add User to Menu
    userListMenu:addItem(user[1], {removeUserButton, changePasswordButton})
  end

  userListMenu:render()
end

function userAddButton(button)
  username, password = ProjectNukeCoreAuthenticationHandler.drawLoginGUI(false)
  userTableInit()
end

function userRemoveButton(button)
  removeUser(button:getValue())
  userTableInit()
end

function userChangePasswordButton(button)
  
  userTableInit()
end

--[[
================================================================================
  User Database
================================================================================
]]--
function saveUserDatabase()
  fs.delete(userDatabasePath)
  ProjectNukeFileUtil.SaveTable(userDatabase, userDatabasePath)
end

function addUser(username, password)
  table.insert(userDatabase, {username, password})
  saveUserDatabase()
end

function removeUser(username)
  index = getUserIndex(username)

  if (index > -1) then
    table.remove(userDatabase, index)
    saveUserDatabase()
  end
end

function getUserIndex(username)
  for index, user in ipairs(userDatabase) do
    if (user[1] == username and username ~= nil) then
      return index
    end
  end

  return -1
end

function testUserCredentials(tryUsername, tryPassword)
  if (tryUsername == nil or tryPassword == nil) then
    return false
  end

  for key, user in ipairs(userDatabase) do
    dbUsername = user[1]
    dbPassword = user[2]

    if (dbUsername == tryUsername and dbPassword == tryPassword) then
      return true
    end
  end

  return false
end

--[[
================================================================================
  Authentication Server
================================================================================
]]--
function runAuthServer()
  -- Await Authentication Message
  local packet = ProjectNukeCoreRednetHandler.WaitForPacket(ProjectNukeCorePackets.AuthenticationRequestPacket)

  if (packet ~= nil) then
    -- Process
    local packetData = packet:getData()

    local username = packetData[1]
    local password = packetData[2]

    -- Send Response
    local authenticationResponsePacket = ProjectNukeCorePackets.AuthenticationResponsePacket
    
    responseData = {
      [1] = testUserCredentials(username, password), -- Authentication Status
      [2] = ProjectNukeEncryptionUtil.SHA256(username .. password) -- Username/Password Checksum
    }

    authenticationResponsePacket:setData(responseData)
    ProjectNukeCoreRednetHandler.SendPacket(authenticationResponsePacket)
  end
end