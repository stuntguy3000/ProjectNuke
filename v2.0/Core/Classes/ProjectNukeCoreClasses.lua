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