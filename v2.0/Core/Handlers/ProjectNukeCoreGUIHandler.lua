--[[

================================================================================

ProjectNukeCoreGUIHandler
Provides common GUI handling functions and utilities

================================================================================

Author: stuntguy3000

--]]

local mainWindow = window.create(term.current(), 1, 1, 51, 21) -- The main window for drawing graphic elements
local messageWindow = window.create(term.current(), 1, 1, 51, 21) -- A window designed to overlay popup messages
local authenticationWindow = window.create(term.current(), 1, 1, 51, 21) -- A window designed for Authentication requests
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

         -- Is it the right size?
         monitorSize = {monitor.getSize()} -- Width/Height Respectively

         if (monitorSize[1] == 50 and monitorSize[2] == 19) then
            -- Create a message window for the message
            monitorWindow = window.create(term.current(), 1, 1, 51, 21)

            -- Fill the computer terminal with a generic message.
            Fill(colours.lightGrey, monitorWindow)
            WriteCenteredText("See monitor for output.", 10, colours.grey, colours.lightGrey, monitorWindow)

            -- Recreate the windows using the monitor
            mainWindow = window.create(monitor, 1, 1, 50, 19)
            --messageWindow = window.create(monitor, 1, 1, 50, 19)
            return
         else
            DrawPopupMessage({"Attached monitors are not compatible.", "Only a monitor that is 5x3 in size can be used."}, colours.red, 5)
         end
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
      local clickableItem = GetClickableItemAtPos(p2, p3)

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
      local textbox = GetClickableItemAtPos(cursorX, cursorY)
      local pressedKey = p1

      if (textbox ~= nil) then
         actionFunction = textbox:getActionFunction()

         if (actionFunction == TextboxClickHandler) then
            if (event == "char") then
               local textboxValue = textbox:getValue() or ""

               -- Maximum length check
               if (#textboxValue <= textbox:getWidth()) then
                  textboxValue = textboxValue .. pressedKey
                  textbox:setValue(textboxValue)

                  textboxX, textboxY, width, height = textbox:getSize()
                  RefreshTextbox(textbox)
               end
            elseif (event == "key") then
               if (pressedKey == keys.backspace) then
                  textboxValue = textbox:getValue() or ""

                  if (#textboxValue > 0) then
                     textboxValue = textboxValue:sub(1, #textboxValue - 1)
                     textbox:setValue(textboxValue)

                     textboxX, textboxY, width, height = textbox:getSize()

                     -- Blank over previous character or current one if last character
                     if (cursorX == (textboxX+width)) then
                        DrawBox(colours.white, cursorX, cursorY, cursorX, cursorY, textbox:getWindow())
                     end

                     DrawBox(colours.white, cursorX-1, cursorY, cursorX-1, cursorY, textbox:getWindow())
                     RefreshTextbox(textbox)
                  end
               end
            end
         end
      end
   end

   StartEventListener()
end

function getVisibleWindow()
   if (authenticationWindow ~= nil and authenticationWindow.isVisible()) then
      return authenticationWindow
   elseif (messageWindow ~= nil and messageWindow.isVisible()) then
      return messageWindow
   elseif (mainWindow ~= nil and mainWindow.isVisible()) then
      return mainWindow
   end

   return nil
end

--endregion

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

   -- Draw Title/Subheading Backgrounds
   DrawBox(colours.yellow,    1, 1, 51, 3,   window)
   DrawBox(colours.red,       1, 4, 51, 6,   window)
   DrawBox(colours.lightGrey, 1, 7, 51, 19,  window)

   if (subHeading ~= "") then
      DrawBox(colours.orange, 1, 7, 51, 9, window)
   end

   -- Draw Black Checker Pattern
   -- Gives us three rows of alternating black checkers.
   windowSize = {window.getSize()}

   for xStart = 0, 3, 1 do
      y = 3 - xStart

      for x=0, windowSize[1], 4 do
         DrawBox(colours.black, (xStart + x), (y), (xStart + x + 1), (y), window)
      end
   end

   -- Title text
   WriteCenteredText(title, 5, colours.white, colours.red, window)

   if (subHeading ~= "") then
      WriteCenteredText(subHeading, 8, colours.black, colours.orange, window)
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
   WriteCenteredText("                                                   ", 19, colours.grey, colours.lightGrey, mainWindow)
   WriteCenteredText(message, 19, colours.grey, colours.lightGrey, mainWindow)
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
   button = ProjectNukeCoreClasses.ClickableItem.new(buttonID, buttonValue, buttonText, buttonTextColour, buttonColour, xStart, yStart, width, height, actionFunction, window)
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
function AddTextbox(textboxID, xStart, yStart, width, window)
   -- Draw the textbox
   textbox = ProjectNukeCoreClasses.ClickableItem.new(textboxID, "", "", colours.white, colours.white, xStart, yStart, width, 1, TextboxClickHandler, window)
   textbox:render()

   table.insert(clickableItems, textbox)

   return textbox
end

function RefreshTextbox(clickableItem)
   -- Determine where the cursor goes
   x,y = clickableItem:getPosition()
   width = clickableItem:getWidth()
   id = clickableItem:getID()
   value = clickableItem:getValue()

   window = clickableItem:getWindow()

   -- Render it
   window.setBackgroundColour(colors.white)
   window.setTextColour(colors.black)
   window.setCursorPos(x,y)

   -- Super Simple Password Shielding!
   if (id == "password") then
      value = ""

      for i = 1, string.len(clickableItem:getValue()), 1 do
         value = value .. "*"
      end
   else
      value = clickableItem:getValue() or ""
   end

   window.write(value)

   cursorPosX, cursorPosY = window.getCursorPos()

   if (cursorPosX > (x + width)) then
      window.setCursorPos(cursorPosX - 1, cursorPosY)
      window.setCursorBlink(false)
   else
      window.setCursorBlink(true)
   end

end

function TextboxClickHandler(clickableItem)
   RefreshTextbox(clickableItem)

   StartEventListener()
end

-- Generic
function RemoveClickableItem(clickableItem)
   index = table.indexOfValue(clickableItems, clickableItem)

   if (index > -1) then
      table.remove(clickableItems, index)
   end
end

function GetClickableItemByID(id)
   for i, v in pairs(clickableItems) do
      if (v:getID() == id) then
         return v
      end
   end

   return nil
end

function GetClickableItemAtPos(x, y)
   for i,clickableItem in pairs(clickableItems) do
      if (clickableItem ~= nil and clickableItem:isEnabled() == true) then
         xStart, yStart, width, height = clickableItem:getSize()

         if (x >= xStart and x <= (xStart + width)) then
            if (y >= yStart and y <= (yStart + height)) then
               return clickableItem
            end
         end
      end
   end

   return nil
end

-- Init GUI without monitors when the GUIHandler is loaded.
initGUI(false)