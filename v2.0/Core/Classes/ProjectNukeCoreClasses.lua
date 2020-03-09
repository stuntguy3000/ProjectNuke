-- Application Class
Application = {}
Application.__index = Application

function Application.new(applicationName, applicationID, applicationFileName)
  local self = setmetatable({}, Application)
  self.applicationName = applicationName
  self.applicationID = applicationID
  self.applicationFileName = applicationFileName
  return self
end

function Application.getName(self)
  return self.applicationName
end

function Application.getID(self)
  return self.applicationID
end

function Application.getFileName(self)
  return self.applicationFileName
end
-- Application Class End


-- Clickable Item Class
ClickableItem = {}
ClickableItem.__index = ClickableItem

function ClickableItem.new(id, value, text, textColour, backgroundColour, xStart, yStart, width, height, actionFunction)
  local self = setmetatable({}, ClickableItem)
  
  self.enabled = true
  self.id = id
  self.value = value
  self.text = text
  
  self.textColour = textColour
  self.backgroundColour = backgroundColour
  
  self.xStart = xStart
  self.yStart = yStart
  
  self.actionFunction = actionFunction
  
  width = width - 1
  height = height - 1
  
  if (width < 0) then
    width = 0
  end
  
  if (height < 0) then
    height = 0
  end
  
  self.width = width
  self.height = height
  
  return self
end

function ClickableItem.render(self)
  term.setBackgroundColor(self.backgroundColour)
  term.setTextColor(self.textColour)
  
  paintutils.drawFilledBox(self.xStart, self.yStart, self.xStart + self.width, self.yStart + self.height, self.backgroundColour)
  
  -- Cursor Position = xStart + half the button width minus half the text width
  cursorX = math.ceil(self.xStart + (self.width / 2) - (string.len(self.text) / 2))
  cursorY = (self.yStart + (self.height / 2))
  term.setCursorPos(cursorX, cursorY)
  term.write(self.text)
  
  term.setCursorPos(self.xStart, self.yStart + self.height + 1)
end

function ClickableItem.isEnabled(self)
  return self.enabled
end

function ClickableItem.getID(self)
  return self.id
end

function ClickableItem.getValue(self)
  return self.value
end--[[

================================================================================

  ProjectNukeCore-GUIUtil
    Provides common GUI utilities

================================================================================

  Author: stuntguy3000

--]]

local ProjectNukeGUI = window.create(term.current(),1,1,51,21,true)
local MessageWindow = window.create(ProjectNukeGUI,1,1,51,21,false)

-- Basic drawing items
function DrawBlackSquares(xStart, y) 
  for x=0, 50, 4 do
    paintutils.drawFilledBox(xStart + x, y, xStart + x + 1, y, colors.black)
  end
end

function DrawBaseGUI(title, subHeading)
  ProjectNukeGUI.clear()
  
  -- nil santiy check
  title = title or ""
  subHeading = subHeading or ""
  
  -- Draw Title/Subheading Backgrounds
  paintutils.drawFilledBox(1, 1, 51, 3, colors.yellow)
  paintutils.drawFilledBox(1, 4, 51, 6, colors.red)
  paintutils.drawFilledBox(1, 7, 51, 9, colors.orange)
  paintutils.drawFilledBox(1, 10, 51, 19, colors.lightGray)
  
  -- Draw Black Checker Pattern
  DrawBlackSquares(2, 1)
  DrawBlackSquares(1, 2)
  DrawBlackSquares(0, 3)
  
  -- Title text
  DrawCenteredText(title, 5, colors.white, colors.red, ProjectNukeGUI)
  DrawCenteredText(subHeading, 8, colors.black, colors.orange, ProjectNukeGUI)
end

function DrawCenteredText(text, yVal, textColor, backgroundColor, terminal) 
  local length = string.len(text) 
  local width = terminal.getSize()
  local minus = math.floor(width-length) 
  local x = math.floor(minus/2) 

  terminal.setCursorPos(x+1,yVal) 
  terminal.write(text)
end

function DrawStatus(message, terminal)
  terminal.setTextColor(colors.gray)
  DrawCenteredText("                   ", 19, terminal)
  DrawCenteredText(message, 19, terminal)
end

-- Used to draw a error messages
-- Message is assumed to be a table
--  Table: yValue messageText
function DrawSuccessMessages(messageLines, timeout)
  MessageWindow.setVisible(true)
  MessageWindow.clear()
  
  FillScreen(colors.green, MessageWindow)
  
  MessageWindow.setBackgroundColor(colors.green)
  MessageWindow.setTextColor(colors.black)
  
  for yValue, message in pairs(messageLines) do
    DrawCenteredText(message, yValue, MessageWindow)
  end
  
  sleep(timeout)
  MessageWindow.setVisible(false)
  ProjectNukeGUI.redraw()
end

-- Used to draw a error messages
-- Message is assumed to be a table
--  Table: yValue messageText
function DrawErrorMessages(messageLines, timeout)
  MessageWindow.setVisible(true)
  MessageWindow.clear()
  
  FillScreen(colors.red, MessageWindow)
  
  MessageWindow.setBackgroundColor(colors.red)
  MessageWindow.setTextColor(colors.black)
  
  for yValue, message in pairs(messageLines) do
    DrawCenteredText(message, yValue, MessageWindow)
  end
  
  sleep(timeout)
  MessageWindow.setVisible(false)
  ProjectNukeGUI.redraw()
end

function FillScreen(colour, terminal)
  terminal = terminal or ProjectNukeGUI

  width, height = terminal.getSize()
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
		AddButton(buttonID, toggleStatus, "No", colors.white, colors.orange, xStart, yStart, width, height, ToggleButtonHandler)
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


function ClickableItem.getActionFunction(self)
  return self.actionFunction
end

function ClickableItem.getSize(self)
  return self.xStart, self.yStart, self.width, self.height
end
-- End Clickable Item Class


-- Config Class
Config = {}
Config.__index = Config

function Config.new(encryptionKey, enabledApplications)
  local self = setmetatable({}, Config)
  
  self.encryptionKey = encryptionKey
  self.enabledApplications = enabledApplications
  
  return self
end

function Config.getEncryptionKey(self)
  return self.encryptionKey
end

function Config.getEnabledApplications(self)
  return self.enabledApplications
end

function Config.isValid(self)
  return (self.encryptionKey ~= null and self.enabledApplications ~= null)
end
-- Config Class End