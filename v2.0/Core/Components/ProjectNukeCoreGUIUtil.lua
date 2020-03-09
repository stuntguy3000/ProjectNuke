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

function AddButton(buttonID, buttonValue, buttonText, buttonTextColour, buttonColour, xStart, yStart, width, height)
  -- Draw the button
  button = ProjectNukeClassClickableItemClass.new(buttonID, buttonValue, buttonText, buttonTextColour, buttonColour, xStart, yStart, width, height)
  button:render()
  
  -- Save the button to memory for future reference
  table.insert(ClickableItems, button)
end

function GetClickableItem(x, y)
  for i,clickableItem in pairs(ClickableItems) do
    if (clickableItem ~= nil) then
      xStart = clickableItem:getXStart()
      yStart
      xEnd
      yEnd =
    end
  end
  
  return nil
end