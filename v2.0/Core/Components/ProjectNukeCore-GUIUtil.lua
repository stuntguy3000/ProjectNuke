--[[

================================================================================

  ProjectNukeCore-GUIUtil
    Provides common GUI utilities

================================================================================

  Author: stuntguy3000

--]]

function DrawBaseGUI(Title, SubHeading)
  -- Draw Title/Subheading Backgrounds
  paintutils.drawFilledBox(1, 1, 51, 3, colors.yellow)
	paintutils.drawFilledBox(1, 4, 51, 6, colors.red)
	
  -- Draw Black Checker Pattern
	DrawBlackSquares(2, 1)
	DrawBlackSquares(1, 2)
	DrawBlackSquares(0, 3)
end

local function DrawBlackSquares(xStart, y) 
  for x=0, 50, 4 do
    paintutils.drawFilledBox(xStart + x, y, xStart + x + 1, y, colors.black)
  end
end

function DrawStatus(StatusText)
  
end

function DrawError(Message, Timeout)
  
end
  
function DrawSuccess(Message, Timeout)
  
end