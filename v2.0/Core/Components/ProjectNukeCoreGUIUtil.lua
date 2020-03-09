--[[

================================================================================

  ProjectNukeCore-GUIUtil
    Provides common GUI utilities

================================================================================

  Author: stuntguy3000

--]]

-- Basic drawing items
function DrawBlackSquares(xStart, y) 
  for x=0, 50, 4 do
    paintutils.drawFilledBox(xStart + x, y, xStart + x + 1, y, colors.black)
  end
end

function DrawBaseGUI(title, subHeading)
  term.clear()
  
  -- nil santiy check
  title = title or ""
  subHeading = subHeading or ""
  
  -- Draw Title/Subheading Backgrounds
  paintutils.drawFilledBox(1, 1, 51, 3, colors.yellow)
  paintutils.drawFilledBox(1, 4, 51, 6, colors.red)
  
  -- Draw Black Checker Pattern
  DrawBlackSquares(2, 1)
  DrawBlackSquares(1, 2)
  DrawBlackSquares(0, 3)

  -- Title text
  term.setBackgroundColor(colors.red)
  term.setTextColor(colors.white)
  DrawCenteredText(title, 5)

  -- Subheading Text
  paintutils.drawFilledBox(1, 7, 51, 9, colors.orange)
  term.setTextColor(colors.black)
  DrawCenteredText(subHeading, 8)
  paintutils.drawFilledBox(1, 10, 51, 19, colors.lightGray)
end

function DrawCenteredText(text, yVal) 
  local length = string.len(text) 
  local width = term.getSize()
  local minus = math.floor(width-length) 
  local x = math.floor(minus/2) 

  term.setCursorPos(x+1,yVal) 
  term.write(text)
end

function DrawStatus(message)
  term.setTextColor(colors.gray)
  DrawCenteredText("                                                                                                                  ", 19)
  DrawCenteredText(message, 19)
end

-- Used to draw a error messages
-- Message is assumed to be a table
--  Table: yValue messageText
function DrawSuccessMessages(messageLines, timeout)
  term.clear()
  
  FillScreen(colors.green)
  
  term.setBackgroundColor(colors.green)
  term.setTextColor(colors.black)
  
  for yValue, message in pairs(messageLines) do
    DrawCenteredText(message, yValue)
  end
  
  sleep(timeout)
end

-- Used to draw a error messages
-- Message is assumed to be a table
--  Table: yValue messageText
function DrawErrorMessages(messageLines, timeout)
  term.clear()
  
  FillScreen(colors.red)
  
  term.setBackgroundColor(colors.red)
  term.setTextColor(colors.black)
  
  for yValue, message in pairs(messageLines) do
    DrawCenteredText(message, yValue)
  end
  
  sleep(timeout)
end

function FillScreen(colour)
  width, height = term.getSize()
  paintutils.drawFilledBox(0,0,width,height,colour)
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
		AddButton(buttonID, toggleStatus, "Yes", colors.white, colors.green, xStart, yStart, width, height, ToggleButtonHandler)
	else
		AddButton(buttonID, toggleStatus, "No", colors.white, colors.red, xStart, yStart, width, height, ToggleButtonHandler)
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