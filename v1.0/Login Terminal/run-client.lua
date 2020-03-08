-- ===========================
-- 	Required APIs
-- ===========================
os.loadAPI("/script/sha256")

-- ===========================
--  Variables for the login form
-- ===========================
local boxIndex = 0
local textIndex = 0
local username = ""
local password = ""
local textboxLimit = 36
local usernameCursorX = 13
local usernameCursorY = 11
local passwordCursorX = 13
local passwordCursorY = 13
local cursorX = 0
local cursorY = 0

local guiEnabled = true

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
	term.setCursorPos(cursorX, cursorY) 
end

-- ===========================
--  Application Functions
-- ===========================
function performLogin() 
	disableLoginButtons()
	guiEnabled = false
	term.setCursorBlink(false)
	term.setBackgroundColor(colors.lightGray)
	
	-- Perform 10 Authentication Requests
	for i=0,10 do
		if i > 2 then
			setStatus("Performing authentication request... ("..i.."/10)")
		else
			setStatus("Performing authentication request...")
		end
		
		--
		-- Authentication Request Attempt
		--	
		-- Loop 5 times:
		--	Send Broadcast with auth request
		--  Wait 0.2 for response
		--
		
		broadcastString = "AUTH;"..username..";"..sha256.sha256(password)
		
		for i=0,5 do
			rednet.broadcast(broadcastString, "AUTH")
			senderId, message, protocol = rednet.receive("AUTH", 0.2)
			
			if message ~= nil then
				if message == "authenticated" then
					drawSuccess("Access Granted.")
					
					username = ""
					password = ""
					boxIndex = 0
					
					sleep(2)
				else
					drawError("Invalid Credentials.")
					
					password = ""
					boxIndex = 1
					
					sleep(2)
				end
				return
			end
		end
	end
	
	drawError("Unable to contact server.")
	sleep(5)
end

function clearForm()
	username = nil
	password = nil
	
	usernameCursorX = 13
	usernameCursorY = 11
	passwordCursorX = 13
	passwordCursorY = 13
	boxIndex = 0
	cursorX, cursorY = usernameCursorX, usernameCursorY
	
	fillTextBoxes()
end

-- ===========================
-- 	GUI Draw Functions
-- ===========================
function drawSuccess(message)
	term.setBackgroundColor(colors.green)
	paintutils.drawFilledBox(1, 7, 51, 19, colors.green)
	term.setTextColor(colors.black)
	centerText(message, 13)
	setStatus("")
end

function drawError(message)
	term.setBackgroundColor(colors.red)
	paintutils.drawFilledBox(1, 7, 51, 19, colors.red)
	term.setTextColor(colors.black)
	centerText("Unable to authenticate!", 11)
	centerText("Please validate your credentials.", 13)
	setStatus("Error: "..message)
end

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
	centerText("Project Nuke Authentication Terminal", 5)
	term.setBackgroundColor(colors.orange)
end

function drawLogin()
	guiEnabled = true
	term.setTextColor(colors.black)
	
	-- Initial Background
	paintutils.drawFilledBox(1, 7, 51, 9, colors.orange)
	centerText("Please enter your username and password.", 8)
	paintutils.drawFilledBox(1, 10, 51, 19, colors.lightGray)
	
	-- Login Text
	term.setBackgroundColor(colors.lightGray)
	term.setCursorPos(3, 11)
	term.write("Username")
	term.setCursorPos(3, 13)
	term.write("Password")
	
	term.setTextColor(colors.black)
	term.setBackgroundColor(colors.lightGray)

	-- Buttons
	enableLoginButtons()
	
	-- Textboxes
	paintutils.drawFilledBox(13, 11, 49, 11, colors.white)
	paintutils.drawFilledBox(13, 13, 49, 13, colors.white)
	
	term.setBackgroundColor(colors.lightGray)
	setStatus("Ready for credentials")
	fillTextBoxes()
end

function enableLoginButtons()
	paintutils.drawFilledBox(13, 15, 19, 17, colors.red)
	paintutils.drawFilledBox(43, 15, 49, 17, colors.green)
	
	term.setTextColor(colors.white)
	
	term.setBackgroundColor(colors.red)
	term.setCursorPos(14, 16)
	term.write("Clear")
	
	term.setBackgroundColor(colors.green)
	term.setCursorPos(44, 16)
	term.write("Login")
end

function disableLoginButtons()
	paintutils.drawFilledBox(13, 15, 19, 17, colors.gray)
	paintutils.drawFilledBox(43, 15, 49, 17, colors.gray)
	
	term.setTextColor(colors.black)
	
	term.setBackgroundColor(colors.gray)
	term.setCursorPos(14, 16)
	term.write("Clear")
	
	term.setBackgroundColor(colors.gray)
	term.setCursorPos(44, 16)
	term.write("Login")
end

-- ===========================
-- 	Application Loop Functions
--
--		These functions will loop, constantly.
-- ===========================
function eventListener()
	local event, p1, p2, p3 = os.pullEvent()
	
	if guiEnabled == false then
		end

	if event == "key" then
		key = p1
		if key == keys.enter then
			performLogin()
			drawLogin()
		elseif key == keys.tab then
			if boxIndex == 0 then
				boxIndex = 1
			elseif boxIndex == 1 then
				boxIndex = 0
			end
		elseif key == keys.backspace then
			if boxIndex == 0 then
				if username ~= nil then
					username = username:sub(1, username:len() - 1)
				end
			elseif boxIndex == 1 then
				if password ~= nil then
					password = password:sub(1, password:len() - 1)
				end
			end
		else
			return
		end
		
		fillTextBoxes()
	elseif event == "char" then
		if boxIndex == 0 then
			if username == nil then
				username = p1
			elseif username:len() <= textboxLimit then
				username = username .. p1
			end
		elseif boxIndex == 1 then
			if password == nil then
				password = p1
			elseif password:len() <= textboxLimit then
				password = password .. p1
			end
		end
	
		fillTextBoxes()
	elseif event == "mouse_click" then
		local x = tonumber(p2)
		local y = tonumber(p3)
		
		-- Button Coordinates
		--
		-- Login: 		(43, 15) to (49, 17)
		-- Clear: 		(13, 15) to (19, 17)
		-- Username: 	(13, 11) to (49, 11)
		-- Password: 	(13, 13) to (49, 13)
		--
		
		if x >= 43 and x <= 49 and y >= 15 and y <= 17 then
			performLogin() 
			drawLogin()
		elseif x >= 13 and x <= 19 and y >= 15 and y <= 17 then
			clearForm() 
			drawLogin()
		elseif x >= 13 and x <= 49 and y >= 11 and y <= 11 then
			boxIndex = 0
			fillTextBoxes()
		elseif x >= 13 and x <= 49 and y >= 13 and y <= 13 then
			boxIndex = 1
			fillTextBoxes()
		end
	end
end

function fillTextBoxes()
	paintutils.drawFilledBox(13, 11, 49, 11, colors.white)
	paintutils.drawFilledBox(13, 13, 49, 13, colors.white)
	
	term.setBackgroundColor(colors.white)
	term.setTextColor(colors.black)
	term.setCursorBlink(true)
	term.setCursorPos(13, 11)
	
	if username ~= nil then
		term.write(username)
		usernameCursorX, usernameCursorY = term.getCursorPos()
	end
		
	if password ~= nil then
		term.setCursorPos(13, 13)
		length = password:len()
		for i=1,password:len() do
			term.write("*")
		end
		passwordCursorX, passwordCursorY = term.getCursorPos()
	end
	
	if boxIndex == 0 then
		if username ~= nil and username:len() > textboxLimit then
			term.setCursorBlink(false)
		else
			term.setCursorBlink(true)
		end
		
		term.setCursorPos(usernameCursorX, usernameCursorY)
	else
		if password ~= nil and password:len() > textboxLimit then
			term.setCursorBlink(false)
		else
			term.setCursorBlink(true)
		end
	
		term.setCursorPos(passwordCursorX, passwordCursorY)
	end
end

-- ===========================
-- 	Run Application
-- ===========================
rednet.open("back")

drawHeader()
drawLogin()

while true do
	eventListener()
end