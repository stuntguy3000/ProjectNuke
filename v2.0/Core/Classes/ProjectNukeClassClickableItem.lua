-- Clickable Item Class
local ProjectNukeClassClickableItemClass = {}
ProjectNukeClassClickableItemClass.__index = ProjectNukeClassClickableItemClass

function ProjectNukeClassClickableItemClass.new(id, value, buttonText, buttonTextColour, buttonColour, xStart, yStart, width, height)
  local self = setmetatable({}, ProjectNukeClassClickableItemClass)
  
  self.enabled = true
  self.id = id
  self.value = value
  self.xStart = xStart
  self.yStart = yStart
  
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

function ProjectNukeClassClickableItemClass.getName(self)
  return self.applicationName
end
-- End Clickable Item Class