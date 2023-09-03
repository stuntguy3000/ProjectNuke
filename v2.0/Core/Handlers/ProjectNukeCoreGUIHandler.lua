--[[

================================================================================

ProjectNukeCoreGUIHandler
Provides common GUI handling functions and utilities

================================================================================

Author: stuntguy3000

--]]

--- Window Objects for 
local mainWindow = nil -- The main window for drawing graphic elements
local messageWindow = nil -- A window designed to overlay popup messages

local monitors = { peripheral.find("monitor") }

function initGui(connectMonitor)
   if (connectMonitor == true and ProjectNukeCoreConfigurationHandler.getConfig().monitorSupport) then
      -- Use an attached monitor if present
      
      if (monitors ~= nil and #monitors > 0) then
         local monitor = monitors[1]

         -- Is it the right size?
         monitorSize = {monitor.getSize()} -- Width/Height Respectively

         if (monitorSize[1] == 50 and monitorSize[2] == 19) then
            -- Fill the computer terminal with a generic message.
            FillWindow(colours.lightGrey, messageWindow)
            DrawCenteredText("See monitor for output.", 10, colours.grey, colours.lightGrey, messageWindow)
            messageWindow.setCursorPos(1,1)

            -- Recreate the windows using the monitor
            mainWindow = window.create(monitor, 1, 1, 50, 19)
            messageWindow = window.create(monitor, 1, 1, 50, 19)
            return
         else
            drawPopupMessage({"Attached monitors are not compatible.", "Only a monitor that is 5x3 in size can be used."}, colours.red, 5)
         end
      end
   else
      mainWindow = window.create(term.current(), 1, 1, 51, 21)
      messageWindow = window.create(term.current(), 1, 1, 51, 21)
   end
end

-- Barring this code for now, need to decide on an approach for monitor support.

-- Basic drawing items
function DrawBlackSquares(xStart, y)
   for x=0, 50, 4 do
      DrawFilledBoxInWindow(colours.black, xStart + x, y, xStart + x + 1, y)
   end
end

function DrawBaseGUI(title, subHeading)
   clearGUI()

   -- nil santiy check
   title = title or ""
   subHeading = subHeading or ""

   -- Draw Title/Subheading Backgrounds
   DrawFilledBoxInWindow(colours.yellow, 1, 1, 51, 3)
   DrawFilledBoxInWindow(colours.red, 1, 4, 51, 6)
   DrawFilledBoxInWindow(colours.lightGrey, 1, 7, 51, 19)

   if (subHeading ~= "") then
      DrawFilledBoxInWindow(colours.orange, 1, 7, 51, 9)
   end

   -- Draw Black Checker Pattern
   DrawBlackSquares(2, 1)
   DrawBlackSquares(1, 2)
   DrawBlackSquares(0, 3)

   -- Title text
   DrawCenteredText(title, 5, colours.white, colours.red)

   if (subHeading ~= "") then
      DrawCenteredText(subHeading, 8, colours.black, colours.orange)
   end
end

function DrawCenteredText(text, yVal, textcolour, backgroundcolour, window)
   window = window or mainWindow

   local length = string.len(text)
   local width = window.getSize()
   local minus = math.floor(width-length)
   local x = math.floor(minus/2)

   window.setBackgroundColour(backgroundcolour)
   window.setTextColour(textcolour)

   window.setCursorPos(x+1,yVal)
   window.write(text)
end

function DrawStatus(message, window)
   window = window or mainWindow

   DrawCenteredText("                                                   ", 19, colours.grey, colours.lightGrey, window)
   DrawCenteredText(message, 19, colours.grey, colours.lightGrey, window)
end

-- Used to draw a status message
function drawPopupMessage(messageLines, backgroundColour, timeout)
   messageWindow.clear()

   -- Setup GUI
   FillWindow(backgroundColour, messageWindow)
   messageWindow.setTextColour(colours.black)

   -- Find Middle Y Value
   messageWindowWidth, messageWindowHeight = messageWindow.getSize()
   yValue = math.ceil(messageWindowHeight / 2) - #messageLines

   for i, message in ipairs(messageLines) do
      DrawCenteredText(message, yValue + i, colours.white, backgroundColour, messageWindow)
   end

   messageWindow.redraw()
   sleep(timeout)
   mainWindow.redraw(true)
end

-- Todo, refactor into drawPopupMessage
function DrawCriticalError(messageLines)
   clearGUI()
   FillWindow(colours.red, mainWindow)

   -- Inject Header
   messageLines[3] = "»»»»» CRITICAL SYSTEM ERROR «««««"

   -- Draw Text   
   mainWindow.setTextColour(colours.black)
   for yValue, message in pairs(messageLines) do
      DrawCenteredText(message, yValue, colours.white, colours.red, mainWindow)
   end

   -- Add Reboot Button
   AddButton("Reboot", nil, "Reboot", colours.white, colours.blue, 21, 17, 10, 1, RebootButtonCommandHandler)

   StartEventListener()
end


-- Clickable Items
local ClickableItems = {}

function clearGUI()
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

   --term.clear()
   --term.setCursorBlink(false)
   --term.setCursorPos(1,1)

   if (monitors ~= nil and #monitors > 0 and ProjectNukeCoreConfigurationHandler.getConfig().monitorSupport) then
      for i, monitor in ipairs(monitors) do
         monitor.clear()
      end
   end

   ClickableItems = {}
end

function AddButton(buttonID, buttonValue, buttonText, buttonTextColour, buttonColour, xStart, yStart, width, height, actionFunction)
   -- Draw the button
   button = ProjectNukeCoreClasses.ClickableItem.new(buttonID, buttonValue, buttonText, buttonTextColour, buttonColour, xStart, yStart, width, height, actionFunction)
   button:render(mainWindow)

   -- Save the button to memory for future reference
   table.insert(ClickableItems, button)
end

function AddToggleButton(buttonID, toggleStatus, xStart, yStart, width, height)
   if (toggleStatus == "YES") then
      AddButton(buttonID, toggleStatus, "Yes", colours.white, colours.green, xStart, yStart, width, height, ToggleButtonHandler)
   else
      AddButton(buttonID, toggleStatus, "No", colours.white, colours.red, xStart, yStart, width, height, ToggleButtonHandler)
   end
end

function GetClickableItemByID(id)
   for i, v in pairs(ClickableItems) do
      if (v:getID() == id) then
         return v
      end
   end

   return nil
end


function GetToggleButtons()
   AllToggleButtons = {}

   for i, v in pairs(ClickableItems) do
      if (v:getActionFunction() == ToggleButtonHandler) then
         table.insert(AllToggleButtons, v)
      end
   end

   return AllToggleButtons
end

function RemoveToggleButton(clickableItem)
   index = table.indexOf(ClickableItems, clickableItem)
   table.remove(ClickableItems, index)
end

function ToggleButtonHandler(clickableItem)
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
   RemoveToggleButton(clickableItem)

   -- Add a new one!
   AddToggleButton(id, toggleStatus, xStart, yStart, width + 1, height + 1)

   StartEventListener()
end

function AddTextbox(textboxID, xStart, yStart, width)
   -- Draw the textbox
   textbox = ProjectNukeCoreClasses.ClickableItem.new(textboxID, "", "", colours.white, colours.white, xStart, yStart, width, 1, TextboxClickHandler)
   textbox:render(mainWindow)

   table.insert(ClickableItems, textbox)

   return textbox
end

function UpdateTextbox(clickableItem, window)
   window = window or mainWindow

   -- Determine where the cursor goes
   x,y = clickableItem:getPosition()
   width = clickableItem:getWidth()
   value = clickableItem:getValue()

   -- Render it
   window.setBackgroundColour(colors.white)
   window.setTextColour(colors.black)
   window.setCursorPos(x,y)

   value = clickableItem:getValue() or ""
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
   UpdateTextbox(clickableItem)

   StartEventListener()
end

function StartEventListener()
   local event, p1, p2, p3 = os.pullEvent()

   if (event == "mouse_click" or event == "monitor_touch") then
      clickableItem = GetClickableItemAtPos(p2, p3)

      if (clickableItem ~= nil) then
         actionFunction = clickableItem:getActionFunction()

         if (actionFunction ~= nil) then
            actionFunction(clickableItem)
            return nil
         end
      end
   elseif (event == "key" or event == "char") then
      cursorX,cursorY = mainWindow.getCursorPos()
      TextboxAtLocation = GetClickableItemAtPos(cursorX,cursorY)
      pressedKey = p1

      if (TextboxAtLocation ~= nil) then
         actionFunction = TextboxAtLocation:getActionFunction()

         if (actionFunction == TextboxClickHandler) then
            if (event == "char") then
               textboxValue = TextboxAtLocation:getValue() or ""

               -- Maximum length check
               if (#textboxValue <= TextboxAtLocation:getWidth()) then

                  textboxValue = textboxValue .. pressedKey
                  TextboxAtLocation:setValue(textboxValue)

                  textboxX, textboxY, width, height = TextboxAtLocation:getSize()
                  UpdateTextbox(TextboxAtLocation)
               end
            elseif (event == "key") then
               if (pressedKey == keys.backspace) then
                  textboxValue = TextboxAtLocation:getValue() or ""

                  if (#textboxValue > 0) then
                     textboxValue = textboxValue:sub(1, #textboxValue - 1)
                     TextboxAtLocation:setValue(textboxValue)

                     textboxX, textboxY, width, height = TextboxAtLocation:getSize()

                     -- Blank over previous character or current one if last character
                     if (cursorX == (textboxX+width)) then
                        DrawFilledBoxInWindow(colours.white, cursorX, cursorY, cursorX, cursorY, mainWindow)
                     end

                     DrawFilledBoxInWindow(colours.white, cursorX-1, cursorY, cursorX-1, cursorY, mainWindow)

                     UpdateTextbox(TextboxAtLocation)
                  end
               end
            end
         end
      end
   end

   StartEventListener()
end

function GetClickableItemAtPos(x, y)
   for i,clickableItem in pairs(ClickableItems) do
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

-- https://gist.github.com/walterlua/978150/2742d9479cd5bfb3d08d90cfcb014da94021e271
function table.indexOf(t, object)
   if type(t) ~= "table" then error("table expected, got " .. type(t), 2) end

   for i, v in pairs(t) do
      if object == v then
         return i
      end
   end
end

function FillWindow(colour, window)
   window = window or mainWindow
   window.clear()

   x,y = window.getPosition()
   w,h = window.getSize()

   DrawFilledBoxInWindow(colour, x, y, w, h, window)
end

function DrawFilledBoxInWindow(colour, x1, y1, x2, y2, window)
   window = window or mainWindow
   window.setBackgroundColour(colour)
   for xLoop = x1, x2 do
      for yLoop = y1, y2 do
         window.setCursorPos(xLoop, yLoop)
         window.write(" ")
      end
   end
end

function RebootButtonCommandHandler()
   os.reboot()
end

function getMainWindow()
   return mainWindow
end

initGui(false)