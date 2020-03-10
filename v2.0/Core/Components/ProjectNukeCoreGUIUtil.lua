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
  if (window == nil) then
    window = ProjectNukeGUI
  end

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
  if (window == nil) then
    window = ProjectNukeGUI
  end

  DrawCenteredText("                   ", 19, colours.grey, colours.lightGrey, window)
  DrawCenteredText(message, 19, colours.grey, colours.lightGrey, window)
end

-- Used to draw a error messages
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

-- Used to draw a error messages
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

function AddButton(buttonID, buttonValue, buttonText, buttonTextColour, buttonColour, xStart, yStart, width, height, actionFunction)
  -- Draw the button
  button = ProjectNukeCoreClasses.ClickableItem.new(buttonID, buttonValue, buttonText, buttonTextColour, buttonColour, xStart, yStart, width, height, actionFunction)
  button:render()
  
  -- Save the button to memory for future reference
  table.insert(ClickableItems, button)
end

function StartEventListener()
  local event, p1, p2, p3 = os.pullEvent()
  
  if (event == "mouse_click") then
    x = p2
    y = p3
    
    clickableItem = GetClickableItem(x, y)
    
    if (clickableItem ~= nil) then
	  
      actionFunction = clickableItem:getActionFunction()
      if (actionFunction ~= nil) then
        actionFunction(clickableItem)
        return nil
      end
    end
  elseif (event == "key") then
    -- oof, todo
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

function AddToggleButton(buttonID, toggleStatus, xStart, yStart, width, height)
	if (toggleStatus == "YES") then
		AddButton(buttonID, toggleStatus, "Yes", colours.white, colours.green, xStart, yStart, width, height, ToggleButtonHandler)
	else
		AddButton(buttonID, toggleStatus, "No", colours.white, colours.orange, xStart, yStart, width, height, ToggleButtonHandler)
	end
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

function FillWindow(colour, window)
  if (window == nil) then
    window = ProjectNukeGUI
  end
  
  window.clear()
  
  x,y = window.getPosition()
  w,h = window.getSize()
  
  DrawFilledBoxInWindow(colour, x, y, w, h, window)
end

function DrawFilledBoxInWindow(colour, x, y, w, h, window)
  if (window == nil) then
    window = ProjectNukeGUI
  end
  
  window.setBackgroundColour(colour)
  for xLoop = x, w do
    for yLoop = y, h do
      window.setCursorPos(xLoop, yLoop)
      window.write(" ")
    end
  end
end