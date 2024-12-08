--[[

================================================================================

ProjectNukeCoreGUIHandler
Provides common GUI handling functions and utilities

================================================================================

Author: stuntguy3000

--]]

local termWidth, termHeight = term.current().getSize()

local mainWindow = window.create(term.current(), 1, 1, termWidth, termHeight) -- The main window for drawing graphic elements
local messageWindow = window.create(term.current(), 1, 1, termWidth, termHeight) -- A window designed to overlay popup messages
local authenticationWindow = window.create(term.current(), 1, 1, termWidth, termHeight) -- A window designed for Authentication requests
local monitors = { peripheral.find("monitor") }

-- All Active clickableItems in the GUI
local clickableItems = {}

--[[
================================================================================
   Handler Functions
      Functions to support GUI Handling
================================================================================
]]--

-- Used to initalise the Window objects, optionally connecting to a monitor if one is attached.
function initGUI(tryConnectMonitor)
   if (tryConnectMonitor and ProjectNukeCoreConfigurationHandler.getConfig().monitorSupport) then
      -- Use an attached monitor if present

      if (monitors ~= nil and #monitors > 0) then
         local monitor = monitors[1]
         monitorSize = {monitor.getSize()} -- Width/Height Respectively
         termSize = {term.current().getSize()} -- Width/Height Respectively

         -- Create a message window for the message
         termWindow = window.create(term.current(), 1, 1, termSize[1], termSize[2])

         -- Fill the computer terminal with a generic message.
         Fill(colours.lightGrey, termWindow)
         WriteCenteredText("See monitor for output.", 10, colours.grey, colours.lightGrey, termWindow)

         -- Recreate the windows using the monitor
         mainWindow = window.create(monitor, 1, 1, monitorSize[1], monitorSize[2])
      end
   --else
   --   mainWindow = window.create(term.current(), 1, 1, 51, 21)
   --   messageWindow = window.create(term.current(), 1, 1, 51, 21)
   --   authenticationWindow = window.create(term.current(), 1, 1, 51, 21)
   end
end

function getMainWindow()
   return mainWindow
end

function getAuthenticationWindow()
   return authenticationWindow
end

function clearWindow(window)
   window.clear()
   window.setCursorBlink(false)
   window.setCursorPos(1,1)

   clickableItems = {}
end

function resetGUI()
   if (mainWindow ~= nil) then
      mainWindow.clear()
      mainWindow.setCursorBlink(false)
      mainWindow.setCursorPos(1,1)
   end

   if (messageWindow ~= nil) then
      messageWindow.clear()
      messageWindow.setCursorBlink(false)
      messageWindow.setCursorPos(1,1)
   end

   if (authenticationWindow ~= nil) then
      authenticationWindow.clear()
      authenticationWindow.setCursorBlink(false)
      authenticationWindow.setCursorPos(1,1)
   end

   if (monitors ~= nil and #monitors > 0 and ProjectNukeCoreConfigurationHandler.getConfig().monitorSupport) then
      for i, monitor in ipairs(monitors) do
         monitor.clear()
      end
   end

   messageWindow.setVisible(false)
   authenticationWindow.setVisible(false)
   mainWindow.setVisible(true)

   clickableItems = {}
end

function StartEventListener()
   local event, p1, p2, p3 = os.pullEvent() -- I can't get filtering to work :(

   if (event == "mouse_click" or event == "monitor_touch") then
      local visibleWindow = getVisibleWindow()
      local clickableItem = GetClickableItemAtPos(visibleWindow, p2, p3)

      if (clickableItem ~= nil) then
         actionFunction = clickableItem:getActionFunction()

         if (actionFunction ~= nil) then
            actionFunction(clickableItem)
            return nil
         end
      end
   elseif (event == "key" or event == "char") then
      local visibleWindow = getVisibleWindow()
      local cursorX, cursorY = visibleWindow.getCursorPos()
      local textbox = GetClickableItemAtPos(visibleWindow, cursorX, cursorY)
      local pressedKey = p1

      if (textbox ~= nil) then
         actionFunction = textbox:getActionFunction()

         -- Are we currently typing in a textbox?
         if (actionFunction == TextboxClickHandler) then
            if (event == "char") then
               -- Char: Fired when text is typed on the keyboard
               local text = textbox:getText() or ""

               -- Maximum length check
               if (#text <= textbox:getWidth()) then
                  text = text .. pressedKey
                  textbox:setText(text)

                  textboxX, textboxY, width, height = textbox:getSize()

                  RedrawTextbox(textbox)
                  StartEventListener()
                  return
               end
            elseif (event == "key") then
               -- Key: Fired when a key is pressed on the keyboard

               if (pressedKey == keys.backspace) then
                  -- Backspace Handling
                  local text = textbox:getText() or ""

                  -- Is the textbox empty?
                  if (#text > 0) then
                     -- Remove the last character
                     text = text:sub(1, #text - 1)
                     textbox:setText(text)

                     -- Redraw Textbox
                     RedrawTextbox(textbox)
                     StartEventListener()
                     return
                  end
               elseif (pressedKey == keys.tab) then
                  -- Tab Handling
                  local currentIndex = textbox:getValue()
                  local texboxTable = {}

                  -- Generate a set containing texbox indexes
                  for _, clickableItem in pairs(clickableItems) do
                     if (clickableItem:getActionFunction() == TextboxClickHandler) then
                        texboxTable[clickableItem:getValue()] = clickableItem:getID()
                     end
                  end

                  -- Find next Highest Textbox
                  for index, textboxID in pairs(texboxTable) do
                     if (index == (currentIndex + 1)) then
                        -- Focus this Textbox
                        RedrawTextbox(GetClickableItemByID(textboxID))
                        StartEventListener()
                        return
                     end
                  end

                  -- Try to find the LOWEST Index Textbox
                  local lowestIndex = currentIndex
                  local lowestIndexID = textbox:getValue()

                  for index, textboxID in pairs(texboxTable) do
                     if (index < lowestIndex) then
                        lowestIndex = index
                        lowestIndexID = textboxID
                     end
                  end

                  -- Is this textbox already focused?
                  if (lowestIndexID ~= textbox:getValue()) then
                     -- Focus this Textbox
                     RedrawTextbox(GetClickableItemByID(lowestIndexID))
                     StartEventListener()
                     return
                  end
               end
            end
         end
      end
   end

   StartEventListener()
end

function getVisibleWindow()
   if (messageWindow ~= nil and messageWindow.isVisible()) then
      return messageWindow
   elseif (authenticationWindow ~= nil and authenticationWindow.isVisible()) then
      return authenticationWindow
   elseif (mainWindow ~= nil and mainWindow.isVisible()) then
      return mainWindow
   end

   return nil
end

--[[
================================================================================
   Drawing Functions
      Functions which Draw GUI Elements
================================================================================
]]--

-- Draw 
function DrawBaseGUI(title, subHeading, window)
   clearWindow(window)

   -- nil santiy check
   title = title or ""
   subHeading = subHeading or ""

   w,h = mainWindow.getSize()

   -- Draw Title/Subheading Backgrounds
   DrawBox(colours.yellow,    1, 1, w, 3,   window)
   DrawBox(colours.red,       1, 4, w, 6,   window)
   DrawBox(colours.lightGrey, 1, 7, w, h,  window)

   if (subHeading ~= "") then
      DrawBox(colours.orange, 1, 7, w, 9, window)
   end

   -- Draw Black Checker Pattern
   -- Gives us three rows of alternating black checkers.
   for xStart = 0, 3, 1 do
      y = 3 - xStart

      for x=0, w, 4 do
         DrawBox(colours.black, (xStart + x), (y), (xStart + x + 1), (y), window)
      end
   end

   -- Title text
   WriteCenteredText(title, 5, colours.white, colours.red, window)

   if (subHeading ~= "") then
      WriteCenteredText(subHeading, 8, colours.black, colours.orange, window)
   end

   -- Authenticated User (If Present)
   if (ProjectNukeCoreAuthenticationHandler ~= nil and ProjectNukeCoreAuthenticationHandler:isAuthenticated() == true) then
      local authenticatedUser = ProjectNukeCoreAuthenticationHandler:getAuthenticatedUser()

      ProjectNukeCoreGUIHandler.AddButton("GUICurrentUser",
      authenticatedUser,
      " " .. authenticatedUser .. " ",
      colours.black,
      colours.orange,
      w - string.len(authenticatedUser) - 3,
      1,
      string.len(authenticatedUser) + 1,
      1,
      nil, window)

      ProjectNukeCoreGUIHandler.AddButton("GUICurrentUserLogout",
      authenticatedUser,
      " X ",
      colours.white,
      colours.red,
      w - 2,
      1,
      3,
      1,
      nil, window)
   end
end

function DrawBox(colour, x1, y1, x2, y2, window)
   window.setBackgroundColour(colour)
   window.setTextColor(colour)

   for xLoop = x1, x2 do
      for yLoop = y1, y2 do
         window.setCursorPos(xLoop, yLoop)
         window.write(" ")
      end
   end
end

function Fill(colour, window)
   x,y = window.getPosition()
   w,h = window.getSize()

   DrawBox(colour, x, y, w, h, window)
end

--[[
================================================================================
   Write Functions
      Functions which Write Text to the GUI
================================================================================
]]--

-- Write a Centered Text to a Window
function WriteCenteredText(text, yVal, textColour, backgroundColour, window)
   local length = string.len(text)
   local width = window.getSize()
   local minus = math.floor(width-length)
   local x = math.floor(minus/2)

   window.setBackgroundColour(backgroundColour)
   window.setTextColour(textColour)

   window.setCursorPos(x+1,yVal)
   window.write(text)
end

-- Write a Status Message to a Window
function WriteStatus(message)
   w,h = mainWindow.getSize()

   WriteCenteredText("                                                                 ", h, colours.grey, colours.lightGrey, mainWindow)
   WriteCenteredText(message, h, colours.grey, colours.lightGrey, mainWindow)
end

-- Draw a Popup Message 
--    Set Timeout to -1 to indicate a Critical Error
function DrawPopupMessage(messageLines, backgroundColour, timeout)
   -- Setup Message Window 
   mainWindow.setVisible(false)
   messageWindow.setVisible(true)
   messageWindow.clear()

   Fill(backgroundColour, messageWindow)
   messageWindow.setTextColour(colours.black)
   messageWindow.setCursorPos(1,1)

   -- Critical Error Handling
   if (timeout <= 0) then
      clickableItems = {}

      WriteCenteredText("", 2, colours.white, backgroundColour, messageWindow)
      WriteCenteredText("»»»»» CRITICAL SYSTEM ERROR «««««", 3, colours.black, backgroundColour, messageWindow)
      WriteCenteredText("", 4, colours.white, backgroundColour, messageWindow)

      AddButton("Reboot", nil, "Reboot", colours.white, colours.blue, 21, 17, 10, 1, RebootButtonCommandHandler, messageWindow)
   end

   -- Find Middle Y Value
   messageWindowWidth, messageWindowHeight = messageWindow.getSize()
   yValue = math.ceil(messageWindowHeight / 2) - #messageLines

   for i, message in ipairs(messageLines) do
      WriteCenteredText(message, yValue + i, colours.white, backgroundColour, messageWindow)
   end

   -- Critical Error Handling
   if (timeout <= 0) then
      StartEventListener()
   else
      sleep(timeout)
      messageWindow.setVisible(false)
      mainWindow.setVisible(true)
   end
end

--[[
================================================================================
   Clickable Item Handling
      Functions which allow the operation of Clickable Items (Buttons and Textboxes)
================================================================================
]]--

-- Button Specific
function AddButton(buttonID, buttonValue, buttonText, buttonTextColour, buttonColour, xStart, yStart, width, height, actionFunction, window)
   -- Draw the button
   button = ProjectNukeCoreClassesGUI.ClickableItem.new(buttonID, buttonValue, buttonText, buttonTextColour, buttonColour, xStart, yStart, width, height, actionFunction, window)
   button:render()

   -- Save the button to memory for future reference
   table.insert(clickableItems, button)
end

function AddToggleButton(buttonID, toggleStatus, xStart, yStart, width, height, window)
   if (toggleStatus == "YES") then
      AddButton(buttonID, toggleStatus, "Yes", colours.white, colours.green, xStart, yStart, width, height, ToggleButtonHandler, window)
   else
      AddButton(buttonID, toggleStatus, "No", colours.white, colours.red, xStart, yStart, width, height, ToggleButtonHandler, window)
   end
end

function GetToggleButtons()
   AllToggleButtons = {}

   for i, v in pairs(clickableItems) do
      if (v:getActionFunction() == ToggleButtonHandler) then
         table.insert(AllToggleButtons, v)
      end
   end

   return AllToggleButtons
end

function ToggleButtonHandler(clickableItem)
   window = clickableItem:getWindow()
   id = clickableItem:getID()
   xStart, yStart, width, height = clickableItem:getSize()

   toggleStatus = nil

   if (clickableItem:getValue() == "YES") then
      toggleStatus = "NO "
   else
      toggleStatus = "YES"
   end

   clickableItem:setValue(toggleStatus)

   -- Remove the old button from existance
   RemoveClickableItem(clickableItem)

   -- Add a new one!
   AddToggleButton(id, toggleStatus, xStart, yStart, width + 1, height + 1, window)

   StartEventListener()
end

function RebootButtonCommandHandler()
   os.shutdown()
end

-- Textboxes
function AddTextbox(id, index, xStart, yStart, width, window)
   -- Draw the textbox
   textbox = ProjectNukeCoreClassesGUI.ClickableItem.new(id, index, "", colours.white, colours.white, xStart, yStart, width, 1, TextboxClickHandler, window)
   textbox:render()

   table.insert(clickableItems, textbox)

   return textbox
end

function RedrawTextbox(clickableItem)
   -- Determine where the cursor goes
   x,y = clickableItem:getPosition()
   width = clickableItem:getWidth()
   id = clickableItem:getID()
   text = clickableItem:getText() or ""
   window = clickableItem:getWindow()

   -- Redraw Textbox
   DrawBox(colours.white, x, y, x + width, y, textbox:getWindow())

   window.setBackgroundColour(colors.white)
   window.setTextColour(colors.black)
   window.setCursorPos(x,y)

   -- Super Simple Password Shielding!
   if (id == "password") then
      text = ""

      for i = 1, string.len(clickableItem:getText()), 1 do
         text = text .. "*"
      end
   end

   -- Print Text to Window
   window.write(text)

   -- Blink the cursor (unless it is outside the Textbox)
   cursorPosX, cursorPosY = window.getCursorPos()
   if (cursorPosX > (x + width)) then
      window.setCursorPos(cursorPosX - 1, cursorPosY)
      window.setCursorBlink(false)
   else
      window.setCursorBlink(true)
   end
end

function TextboxClickHandler(clickableItem)
   RedrawTextbox(clickableItem)
   StartEventListener()
end

-- Unregister a ClickableItem
function RemoveClickableItem(clickableItem)
   index = table.indexOfValue(clickableItems, clickableItem)

   if (index > -1) then
      table.remove(clickableItems, index)
   else
      -- Debug Message
      DrawPopupMessage({"ClickableItem " .. clickableItem.id .. " was not removed."}, colours.red, 5)
   end
end

-- Unregister ClickableItems by a Prefix Search
function RemoveClickableItemsByPrefix(prefixQuery)
   clickableItem = GetClickableItemByIDSearch(prefixQuery)

   while clickableItem ~= nil do
      RemoveClickableItem(clickableItem)

      clickableItem = GetClickableItemByIDSearch(prefixQuery)
   end
end

-- Unregister ClickableItems belonging to a specific Window
function RemoveClickableItemsForWindow(window)
   clickableItem = GetClickableItemByWindow(window)

   while clickableItem ~= nil do
      RemoveClickableItem(clickableItem)

      clickableItem = GetClickableItemByWindow(window)
   end
end

-- Return a ClickableItem based on it's exact ID, if present
function GetClickableItemByID(id)
   for _, clickableItem in pairs(clickableItems) do
      if (clickableItem:getID() == id) then
         return clickableItem
      end
   end

   return nil
end

   -- Return a ClickableItem based on it's window, if present
function GetClickableItemByWindow(window)
   for _, clickableItem in pairs(clickableItems) do
      if (clickableItem:getWindow() == window) then
         return clickableItem
      end
   end

   return nil
end

-- Return a ClickableItem based on a ID Prefix Search (e.g. A search for ID "Button" will find "ButtonNext")
-- Will only return one object, even if multiple are present
function GetClickableItemByIDSearch(id)
   for _, clickableItem in pairs(clickableItems) do
      if (string.starts(clickableItem:getID(), id)) then
         return clickableItem
      end
   end

   return nil
end

-- Returns a ClickableItem at a set of X Y Coordinates
function GetClickableItemAtPos(window, x, y)
   for _, clickableItem in pairs(clickableItems) do
      if (clickableItem ~= nil and clickableItem:isEnabled() == true) then
         xStart, yStart, width, height = clickableItem:getSize()

         if (clickableItem:getWindow() == window) then
            if (x >= xStart and x <= (xStart + width)) then
               if (y >= yStart and y <= (yStart + height)) then
                  return clickableItem
               end
            end
         end
      end
   end

   return nil
end

-- Init GUI without monitors when the GUIHandler is loaded.
initGUI(false)