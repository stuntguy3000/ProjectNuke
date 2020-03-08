-- ===========================
-- 	Application Variables
-- ===========================
local evacuation = false
local allClear = false

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

function centerTextBlit(text, yVal, colorCodes, background) 
	local width = term.getSize()
	local length = string.len(text) 
	local minus = math.floor(width-length) 
	local x = math.floor(minus/2) 
	
	term.setCursorPos(x+1,yVal) 
	term.blit(text, colorCodes, background)
end

function setStatus()
	term.setCursorPos(1, 19)
	term.setTextColor(colors.gray)
	centerText("                                                           ", 19)
	
	local status = nil
	local colorCodesPrefix = "777777777777777777777777777"
	local backgroundColorCodesPrefix = "888888888888888888888888888"
	local colorCodes = nil
	local backgroundColorCodes = ""
	
	if evacuation then
		status = "Evacuation In Progress"
		colorCodes = "eeeeeeeeeeeeeeeeeeeeee"
	elseif allClear then
		status = "All Clear"
		colorCodes = "555555555"
	else
		status = "System Armed"
		colorCodes = "ffffffffffff"
	end
	
	for i=1,status:len() do
		backgroundColorCodes = backgroundColorCodes .. "8"
	end
	
	centerTextBlit("Ready for Action - Status: "..status, 19, colorCodesPrefix .. colorCodes, backgroundColorCodesPrefix .. backgroundColorCodes)
end

-- ===========================
--  Application Functions
-- ===========================
function sendEvacuate()	
	evacuation = true
	allClear = false
	
	disableEvacButton()
	
	setStatus()
	rednet.host("EMERGENCY", "EMERGENCY-SERVER")

	for i=0,100 do  
	  rednet.broadcast("EVAC", "EMERGENCY")
	  sleep(0.1)	
	end
	
	drawAllClearButton()
end

function sendAllClear()
	allClear = true
	evacuation = false
	
	disableAllClearButton()
	disableEvacButton()
	
	setStatus()
	rednet.host("EMERGENCY", "EMERGENCY-SERVER")

	for i=0,100 do 
	  rednet.broadcast("CLEAR", "EMERGENCY")
	  sleep(0.01)
	end
	
	allClear = false
	drawEvacuateButton()
	setStatus()
end

function disableEvacButton()
	paintutils.drawFilledBox(2, 11, 25, 17, colors.gray)
	
	term.setTextColor(colors.black)
	
	term.setCursorPos(10, 14)
	term.write("Evacuate")
	term.setBackgroundColor(colors.lightGray)
end

function disableAllClearButton()
	paintutils.drawFilledBox(27, 11, 49, 17, colors.gray)
	
	term.setTextColor(colors.black)
	
	term.setBackgroundColor(colors.gray)
	term.setCursorPos(35, 14)
	term.write("All Clear")
	term.setBackgroundColor(colors.lightGray)
end

-- ===========================
-- 	GUI Draw Functions
-- ===========================

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
	centerText("Project Nuke Emergency Notification Server", 5)
	term.setBackgroundColor(colors.orange)
	
	term.setTextColor(colors.black)
	
	-- Initial Background
	paintutils.drawFilledBox(1, 7, 51, 9, colors.orange)
	centerText("Use this interface to send emergency alerts.", 8)
	paintutils.drawFilledBox(1, 10, 51, 19, colors.lightGray)
end

function drawEvacuateButton()
	-- Buttons
	paintutils.drawFilledBox(2, 11, 25, 17, colors.red)
	
	term.setTextColor(colors.white)
	
	term.setCursorPos(10, 14)
	term.setBackgroundColor(colors.red)
	term.write("Evacuate")
	
	term.setBackgroundColor(colors.lightGray)
end

function drawAllClearButton()
	term.setTextColor(colors.black)
	paintutils.drawFilledBox(27, 11, 49, 17, colors.green)
	
	term.setTextColor(colors.white)
	
	term.setBackgroundColor(colors.green)
	term.setCursorPos(35, 14)
	term.write("All Clear")
	
	term.setBackgroundColor(colors.lightGray)
end

-- ===========================
-- 	Application Loop Functions
--
--		These functions will loop, constantly.
-- ===========================
function eventListener()
	local event, p1, p2, p3 = os.pullEvent()
	
	if event == "mouse_click" then
		local x = tonumber(p2)
		local y = tonumber(p3)	
		
		if x >= 2 and x <= 25 and y >= 11 and y <= 17 and evacuation == false and allClear == false then
			sendEvacuate()
		elseif x >= 27 and x <= 49 and y >= 11 and y <= 17 and evacuation == true and allClear == false then
			sendAllClear()
		end
	end
end

-- ===========================
-- 	Run Application
-- ===========================
drawHeader()
drawEvacuateButton()
disableAllClearButton()
 
setStatus()

rednet.open("back")

while true do
	eventListener()
end