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
  {"User1", "Password"}, {"User2", "Password"}
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
    print(table.dump(userDatabase))
  end

  -- Run Server and GUI
  while true do
    parallel.waitForAny(runAuthServer, updateGUI)
  end
end

--[[
================================================================================
  GUI & Pagination
================================================================================
]]--

function updateGUI()
  usersPageNumberMaximum = math.ceil(table.count(userDatabase) / usersPerPage)

  if (usersPageNumber > usersPageNumberMaximum and usersPageNumberMaximum > 0) then
    usersPageNumber = usersPageNumber - 1
  end

  -- Base GUI
  window = ProjectNukeCoreGUIHandler.getMainWindow()
  ProjectNukeCoreGUIHandler.DrawBaseGUI(getDisplayName(), "Users Database", window)

  ProjectNukeCoreGUIHandler.WriteStatus("User Count: " .. table.count(userDatabase))



  -- Pagination Buttons

  if (usersPageNumberMaximum > 1) then
    ProjectNukeCoreGUIHandler.AddButton("userPageBack", nil, "<", colours.white, colours.grey, 4, 17, 3, 1, userPageBackButton, window)
    ProjectNukeCoreGUIHandler.AddButton("userPageNumber", nil, usersPageNumber, colours.white, colours.lightGrey, 7, 17, 3, 1, nil, window)
    ProjectNukeCoreGUIHandler.AddButton("userPageForward", nil, ">", colours.white, colours.grey, 10, 17, 3, 1, userPageForwardButton, window)
  end

  -- Buttons
  ProjectNukeCoreGUIHandler.AddButton("addUser", nil, "Add User", colours.white, colours.green, 39, 17, 10, 1, userAddButton, window)

  -- Print User List
  baseIndex = (usersPageNumber - 1) * usersPerPage
  for i = 1, usersPerPage, 1 do
    local userEntry = userDatabase[i + baseIndex]

    if (userEntry ~= nil) then
      local username = userEntry[1]

      -- Draw Label
      window.setTextColour(colours.black)
      window.setBackgroundColour(colours.lightGrey)
      window.setCursorPos(4, 11 + i)
      window.write(username)

      -- Draw Action Button
      ProjectNukeCoreGUIHandler.AddButton(username, username, "Delete", colours.white, colours.red, 41, 11 + i, 8, 1, userDeleteButton, window)
    end
  end

  ProjectNukeCoreGUIHandler.StartEventListener()
end

-- Button Handlers
function userPageBackButton()
  if (usersPageNumber > 1) then
    usersPageNumber = usersPageNumber - 1
    updateGUI()
  else
    ProjectNukeCoreGUIHandler.StartEventListener()
  end
end

function userPageForwardButton()
  if (usersPageNumber < usersPageNumberMaximum) then
    usersPageNumber = usersPageNumber + 1
    updateGUI()
  else
    ProjectNukeCoreGUIHandler.StartEventListener()
  end
end

function userAddButton(button)
  ProjectNukeCoreAuthenticationHandler.drawLoginGUI(false)

  -- Login GUI Exited, update GUI.
  updateGUI()
end

function userDeleteButton(button)
  window = ProjectNukeCoreGUIHandler.getMainWindow()
  window.setCursorPos(1, 1)
  window.write(button:getValue())

  removeUser(button:getValue())

  updateGUI()
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
  for key, user in ipairs(userDatabase) do
    dbUsername = user[1]
    dbPassword = user[2]

    if (dbUsername == tryUsername and dbPassword == tryPassword and tryUsername ~= nil and tryPassword ~= nil and dbUsername ~= nil and dbPassword ~= nil) then
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
  print(table.dump(ProjectNukeCorePackets.AuthenticationRequestPacket))

  local packet = ProjectNukeCoreRednetHandler.WaitForPacket(ProjectNukeCorePackets.AuthenticationRequestPacket, 1)

  if (packet ~= nil) then
    -- Process
    local packetData = packet:getData()

    print(packetData)
    print(table.dump(packetData))

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