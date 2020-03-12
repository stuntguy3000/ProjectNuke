--[[

================================================================================

  ProjectNukeCoreGUIUtil
    Provides common GUI utilities

================================================================================

  Author: stuntguy3000

--]]

ProjectNukeGUI = window.create(term.current(),1,1,51,21)
MessageWindow = window.create(term.current(),1,1,51,21)

-- Basic drawing items
function DrawBlackSquares(xStart, y) 
  for x=0, 50, 4 do
	DrawFilledBoxInWindow(colours.black, xStart + x, y, xStart + x + 1, y)
  end
end

function DrawBaseGUI(title, subHeading)
  -- nil santiy check
  title = title or ""
  subHeading = subHeading or ""
  
  -- Draw Title/Subheading Backgrounds
  DrawFilledBoxInWindow(colours.yellow, 1, 1, 51, 3)
  DrawFilledBoxInWindow(colours.red, 1, 4, 51, 6)
  DrawFilledBoxInWindow(colours.orange, 1, 7, 51, 9)
  DrawFilledBoxInWindow(colours.lightGrey, 1, 10, 51, 19)
  
  -- Draw Black Checker Pattern
  DrawBlackSquares(2, 1)
  DrawBlackSquares(1, 2)
  DrawBlackSquares(0, 3)
  
  -- Title text
  DrawCenteredText(title, 5, colours.white, colours.red)
  DrawCenteredText(subHeading, 8, colours.black, colours.orange)
end

function DrawCenteredText(text, yVal, textcolour, backgroundcolour, window) 
  window = window or ProjectNukeGUI

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
  window = window or ProjectNukeGUI

  DrawCenteredText("                                                   ", 19, colours.grey, colours.lightGrey, window)
  DrawCenteredText(message, 19, colours.grey, colours.lightGrey, window)
end

-- Used to draw success messages
-- Message is assumed to be a table
--  Table: yValue messageText
function DrawSuccessMessages(messageLines, timeout)
  MessageWindow.clear()
  
  FillWindow(colours.green, MessageWindow)
  MessageWindow.setTextColour(colours.black)
  
  for yValue, message in pairs(messageLines) do
    DrawCenteredText(message, yValue, colours.white, colours.green, MessageWindow)
  end
  
  MessageWindow.redraw()
  sleep(timeout)
  ProjectNukeGUI.redraw(true)
end

-- Used to draw error messages
-- Message is assumed to be a table
--  Table: yValue messageText
function DrawErrorMessages(messageLines, timeout)
  MessageWindow.clear()
  
  FillWindow(colours.red, MessageWindow)
  MessageWindow.setTextColour(colours.black)
  
  for yValue, message in pairs(messageLines) do
    DrawCenteredText(message, yValue, colours.white, colours.red, MessageWindow)
  end
  
  MessageWindow.redraw()
  sleep(timeout)
  ProjectNukeGUI.redraw(true)
end


-- Clickable Items
local ClickableItems = {}

function ClearGUI(window)
  window = window or ProjectNukeGUI
  
  window.clear()
  window.setCursorBlink(false)
  ClickableItems = {}
end

function AddButton(buttonID, buttonValue, buttonText, buttonTextColour, buttonColour, xStart, yStart, width, height, actionFunction)
  -- Draw the button
  button = ProjectNukeCoreClasses.ClickableItem.new(buttonID, buttonValue, buttonText, buttonTextColour, buttonColour, xStart, yStart, width, height, actionFunction)
  button:render()
  
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
  
  -- Remove the old button from existance
  RemoveToggleButton(clickableItem)
  
  -- Add a new one!
  AddToggleButton(id, toggleStatus, xStart, yStart, width + 1, height + 1)
  
  StartEventListener()
end

function AddTextbox(textboxID, xStart, yStart, width)
  -- Draw the textbox
  textbox = ProjectNukeCoreClasses.ClickableItem.new(textboxID, "", "", colours.white, colours.white, xStart, yStart, width, 1, TextboxClickHandler)
  textbox:render()
  
  table.insert(ClickableItems, textbox)
  
  return textbox
end

function UpdateTextbox(clickableItem, window)
  window = window or ProjectNukeGUI
  
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
  
  if (event == "mouse_click") then
    clickableItem = GetClickableItem(p2, p3)
    
    if (clickableItem ~= nil) then
      actionFunction = clickableItem:getActionFunction()
	  
      if (actionFunction ~= nil) then
        actionFunction(clickableItem)
        return nil
      end
    end
  elseif (event == "key" or event == "char") then
    cursorX,cursorY = ProjectNukeGUI.getCursorPos()
    TextboxAtLocation = GetClickableItem(cursorX,cursorY)
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
					DrawFilledBoxInWindow(colours.white, cursorX, cursorY, cursorX, cursorY, ProjectNukeGUI)
				end
				
				DrawFilledBoxInWindow(colours.white, cursorX-1, cursorY, cursorX-1, cursorY, ProjectNukeGUI)
				
				UpdateTextbox(TextboxAtLocation)
		    end
		  end
		end
      end
    end
  end
  
  StartEventListener()
end

function GetClickableItem(x, y)
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
  window = window or ProjectNukeGUI
  window.clear()
  
  x,y = window.getPosition()
  w,h = window.getSize()
  
  DrawFilledBoxInWindow(colour, x, y, w, h, window)
end

function DrawFilledBoxInWindow(colour, x1, y1, x2, y2, window)
  window = window or ProjectNukeGUI
  window.setBackgroundColour(colour)
  for xLoop = x1, x2 do
    for yLoop = y1, y2 do
      window.setCursorPos(xLoop, yLoop)
      window.write(" ")
    end
  end
end