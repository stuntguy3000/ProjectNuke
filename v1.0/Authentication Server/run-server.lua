-- ================================================
-- run-server.lua
--
--    Author: stuntguy3000
--    Version: 1.0
--  
-- Responsible for main server activities.
--    
--    - Handling Authentication Requests
--    - Links in other scripts including 
--      database management and modem utilities
--    - Responsible for printing to the monitor
--      overall system status
--
-- ================================================ 

local writeLine = common.writeLine

os.loadAPI("/script/util/common")
os.loadAPI("/script/util/userutil")
os.loadAPI("/script/emergency")

-- Begin listening for client requests 
--
-- 	 	 MESSAGE: AUTH;<username>;<password>
--							   SHA256 Encrypted
--
--     AUTH;([\s\S])+;([A-Fa-f0-9]){64}
--

common.monitor.clear()
_G["display-line"] = 1

-- ===========================
-- 	Utility Functions
-- ===========================
function centerText(text, yVal) 
	local width = term.getSize()
	local length = string.len(text) 
	local minus = math.floor(width-length) 
	local x = math.floor(minus/2) 
	
	term.setCursorPos(x+1,yVal) 
	term.write(text)
end

function setStatus(message)
	term.setCursorPos(1, 19)
	term.setTextColor(colors.gray)
	centerText("                                                                                                                  ", 19)
	centerText(message, 19)
end

-- Draw authentication server header
function drawHeader()
	paintutils.drawFilledBox(1, 1, 51, 3, colors.yellow)
	paintutils.drawFilledBox(1, 4, 51, 6, colors.red)
	
	function drawBlackSquares(xStart, y) 
		for x=0,50,4 do
			paintutils.drawFilledBox(xStart + x, y, xStart + x + 1, y, colors.black)
		end
	end
	
	drawBlackSquares(2, 1)
	drawBlackSquares(1, 2)
	drawBlackSquares(0, 3)
	
	-- Header Text
	term.setBackgroundColor(colors.yellow)
	
	term.setTextColor(colors.black)
	term.setBackgroundColor(colors.red)
	term.setTextColor(colors.white)
	centerText("Project Nuke Authentication Server", 5)
	term.setBackgroundColor(colors.orange)
	
	-- Subheading Text
	paintutils.drawFilledBox(1, 7, 51, 9, colors.orange)
	term.setTextColor(colors.black)
	centerText("Use this interface to manage user auth.", 8)
	paintutils.drawFilledBox(1, 10, 51, 19, colors.lightGray)
end

function runAuthServer() 
  drawHeader()
  setStatus("Ready for authentication")
  senderId, message, protocol = rednet.receive("AUTH", 2)
  
  if message ~= nil then
    if string.gmatch(message, "AUTH;([\s\S])+;([A-Fa-f0-9]){64}") then 
        stringLength = message:len()
        username = string.sub(message, 6, stringLength - 65)
        password = string.sub(message, stringLength - 63, stringLength)
        
        setStatus("Attempting to authenticate...")
        
        if userutil.doesUserExist(username, password) then
            setStatus("Success for user " .. username)
            rednet.send(senderId, "authenticated", "AUTH")
			sleep(2)
        else
            setStatus("Failure for user " .. username)
            rednet.send(senderId, "invalid credentials", "AUTH")
			sleep(2)
        end
    end
  end
end

while true do
  emergency.listenForSignal()
  
  if emergency.listenForSignal() == true then
    runAuthServer()
  end
end