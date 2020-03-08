-- ================================================
-- emergency
--
--    Author: stuntguy3000
--    Version: 1.0
--  
-- Used for displaying an emergency signal until all clear
-- Assumed rednet is active
--
-- ================================================
-- Begin
os.loadAPI("/script/util/common")

local monitor = common.monitor
local timeSinceAnimation = 0
local w,h = monitor.getSize()
local white = true

emergencyActive = false

function centerText(text, yVal) 
  length = string.len(text) 
  minus = math.floor(w-length) 
  x = math.floor(minus/2) 
  monitor.setCursorPos(x+1,yVal) 
  monitor.write(text)
end

-- This is to be executed as a subroutine. During an emergency the emergency server will flood packets for 30 seconds or until all machines have responded
function listenForSignal() 
  senderId, message, protocol = rednet.receive("EMERGENCY", 0.1)
  
  if message ~= nil then
      if message == "CLEAR" and emergencyActive == true then
        monitor.clear()
      
        local middle = math.ceil(h / 2)

        print(middle)
        paintutils.drawFilledBox(1, 1, w, h, colors.green)
          
        centerText("ALL CLEAR", middle)
        centerText("ALL CLEAR", middle+2)
        centerText("ALL CLEAR", middle-2)
        
        sleep(15)
        monitor.clear()
        paintutils.drawFilledBox(1, 1, w, h, colors.black)
        
        os.reboot()
      elseif message == "EVAC" and emergencyActive == false then
        emergencyActive = true
        
        monitor.clear()
        paintutils.drawFilledBox(1, 1, w, h, colors.red)
      end
  end
  
  if emergencyActive == true then
    showEvacScreen()
  end
  
  return emergencyActive == false
end

function showEvacScreen()
      w,h = monitor.getSize()
        timeSinceAnimation = timeSinceAnimation + 1
        
        if timeSinceAnimation == 10 then
          white = not white
          timeSinceAnimation = 0
        end
        
        local middle = math.ceil(h / 2)
        
        if white == true then monitor.setTextColor(colors.white) else monitor.setTextColor(colors.black) end
        
        centerText("=== EMERGENCY ===", middle - 3)
        
        if white == true then
          monitor.setTextColor(colors.black)
        else
          monitor.setTextColor(colors.white)
        end
        
        centerText("EMERGENCY IN PROCESS", middle - 1)
        centerText("EVACUATE FACILITY", middle + 1)
        
        if white == true then
          monitor.setTextColor(colors.white)
        else
          monitor.setTextColor(colors.black)
        end
        
        centerText("=== EMERGENCY ===", middle + 3)
  
end