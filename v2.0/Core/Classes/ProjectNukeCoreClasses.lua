--[[

================================================================================

  ProjectNukeCoreObjects
    A generic class containing all Lua class objects used by various components and applications

================================================================================

  Author: stuntguy3000

--]]

-- Clickable Item Object
ClickableItem = {}
ClickableItem.__index = ClickableItem

function ClickableItem.new(id, value, text, textColour, backgroundColour, xStart, yStart, width, height, actionFunction, window)
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

  self.window = window

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
  ProjectNukeCoreGUIHandler.DrawBox(self.backgroundColour, self.xStart, self.yStart, self.xStart + self.width, self.yStart + self.height, self.window)

  self.window.setBackgroundColor(self.backgroundColour)
  self.window.setTextColor(self.textColour)

  -- Cursor Position = xStart + half the button width minus half the text width
  cursorX = math.ceil(self.xStart + (self.width / 2) - (string.len(self.text) / 2))
  cursorY = (self.yStart + (self.height / 2))
  self.window.setCursorPos(cursorX, cursorY)
  self.window.write(self.text)

  self.window.setCursorPos(self.xStart, self.yStart + self.height + 1)
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

function ClickableItem.getWindow(self)
  return self.window
end

function ClickableItem.setValue(self, value)
  self.value = value
end

function ClickableItem.getActionFunction(self)
  return self.actionFunction
end

function ClickableItem.getSize(self)
  return self.xStart, self.yStart, self.width, self.height
end

function ClickableItem.getWidth(self)
  return self.width
end

function ClickableItem.getPosition(self)
  return self.xStart, self.yStart
end
-- End Clickable Item Object


-- Config Object
Config = {}
Config.__index = Config

function Config.new(encryptionKey, enabledApplication, plantName, monitorSupport)
  local self = setmetatable({}, Config)

  self.encryptionKey = encryptionKey
  self.enabledApplication = enabledApplication
  self.plantName = plantName
  self.monitorSupport = monitorSupport

  return self
end
-- Config Object End

-- Packet Object
Packet = {}
Packet.__index = Packet

function Packet.new(id, data)
  local self = setmetatable({}, Packet)

  self.id = id
  self.data = data

  return self
end

function Packet.getID(self)
  return self.id
end

function Packet.getData(self)
  return self.data
end

function Packet.setData(self, data)
  self.data = data
end
-- Packet Object End
