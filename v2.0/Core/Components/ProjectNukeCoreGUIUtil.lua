--[[

================================================================================

  ProjectNukeCore-GUIUtil
    Provides common GUI utilities

================================================================================

  Author: stuntguy3000

--]]

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
  length = string.len(text) 
  width = term.getSize()
  minus = math.floor(width-length) 
  x = math.floor(minus/2) 

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
  
  paintutils.drawFilledBox(1, 7, 51, 19, colors.green)
  
  term.setBackgroundColor(colors.green)
  term.setTextColor(colors.black)
  
  for yValue, message in pairs(messageLines) do
    DrawCenteredText(message, yValue)
  end
  
  DrawStatus("")
  
  sleep(timeout)
end

-- Used to draw a error messages
-- Message is assumed to be a table
--  Table: yValue messageText
function DrawErrorMessages(lines, timeout)
  term.clear()
  
  paintutils.drawFilledBox(1, 7, 51, 19, colors.red)
  
  term.setBackgroundColor(colors.red)
  term.setTextColor(colors.black)
  
  for yValue, message in pairs(messageLines) do
    DrawCenteredText(message, yValue)
  end
  
  DrawStatus("")
  
  sleep(timeout)
end