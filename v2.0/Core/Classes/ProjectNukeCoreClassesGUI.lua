--[[

================================================================================

  ProjectNukeCoreClassesGui
    A generic class containing all Lua GUI class objects used by various components and applications

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

-- MenuItem Object
MenuItem = {}
MenuItem.__index = MenuItem

function MenuItem.new(menu, itemText, buttonText, buttonColour, buttonValue, buttonActionFunction)
  local self = setmetatable({}, MenuItem)

  -- Assign the required parameters
  self.menu = menu
  self.itemText = itemText
  self.buttonText = buttonText
  self.buttonColour = buttonColour
  self.buttonValue = buttonValue;
  self.buttonActionFunction = buttonActionFunction;
  
  return self
end

-- Menu Object
Menu = {}
Menu.__index = Menu

function Menu.new(id, window, xStart, yStart, width, itemsPerPage)
  return Menu.new(id, window, xStart, yStart, width, itemsPerPage, nil, nil, nil)
end

function Menu.new(id, window, xStart, yStart, width, itemsPerPage, actionButtonText, actionButtonColour, actionButtonFunction)
  local self = setmetatable({}, Menu)

  -- Assign the required parameters
  self.id = id
  self.window = window
  self.xStart = xStart
  self.yStart = yStart
  self.width = width
  self.itemsPerPage = itemsPerPage

  self.actionButtonText = actionButtonText
  self.actionButtonColour = actionButtonColour
  self.actionButtonFunction = actionButtonFunction

  -- Initilize required variables
  self.items = {}
  self.currentPage = 1
  
  return self
end

-- Calculates the total page count of items
function Menu.getTotalPageCount(self)
  return math.ceil(table.count(self.items) / self.itemsPerPage)
end

-- Calculates the GUI height of the Menu
function Menu.getHeight(self)
  return self.itemsPerPage + 1
end

-- Add a Item to the Menu
function Menu.addItem(self, itemText, buttonText, buttonColour, buttonValue, buttonActionFunction)
  -- Create a new MenuItem Object and Store in Item List
  menuItem = MenuItem.new(self, itemText, buttonText, buttonColour, buttonValue, buttonActionFunction)
  self.items[#self.items + 1] = menuItem
end

function Menu.render(self)
  -- Blank Menu
  ProjectNukeCoreGUIHandler.DrawBox(colours.lightGrey, self.xStart, self.yStart, self.xStart + self.width, self.yStart + self:getHeight(), self.window)
  ProjectNukeCoreGUIHandler.RemoveClickableItemsByPrefix("Menu" .. self.id)

  -- Render Items
  for menuItemIndexOffset = 1, self.itemsPerPage do
    local baseIndex = (self.currentPage - 1) * self.itemsPerPage
  
    local menuItemListIndex = baseIndex + menuItemIndexOffset
    local menuItem = self.items[menuItemListIndex]

    if (menuItem ~= nil) then
      local yLevel = self.yStart + (1 * (menuItemIndexOffset - 1))

      -- Setup Cursor
      self.window.setTextColour(colours.grey)
      self.window.setBackgroundColour(colours.lightGrey)
      self.window.setCursorPos(self.xStart, yLevel)

      -- Render menuItem Label
      self.window.write(menuItem.itemText)

      -- Render menuItem Button
      ProjectNukeCoreGUIHandler.AddButton(
        "Menu"  .. self.id .. "Item" .. menuItemListIndex,                -- Button ID
        menuItem.buttonValue,                                             -- Button Value
        " " .. menuItem.buttonText .. " ",                                -- Button Label
        colours.white, menuItem.buttonColour,                             -- Text and Button Colours
        self.xStart + self.width - (string.len(menuItem.buttonText) + 1), -- X Pos (Start of Button, End of row)
        yLevel,                                                           -- Y Pos
        string.len(menuItem.buttonText) + 2,                              -- Button Length
        1,                                                                -- Button Height
        menuItem.buttonActionFunction,                                    -- Action Function
        self.window                                                       -- Window
      )
    end
  end

  -- Render Pagination Controls
  self.window.setTextColour(colours.white)
  self.window.setCursorPos(self.xStart, self.yStart + self:getHeight())

  x,y = self.window.getCursorPos()

  -- If more than one page, introduce navigation controls
  if (self:getTotalPageCount() > 1) then
    -- Render the Back Button
    if (self.currentPage == 1) then
      ProjectNukeCoreGUIHandler.AddButton("Menu" .. self.id .. "PageBack", nil, " ", colours.grey, colours.lightGrey, x, y, 3, 1, nil, self.window)
    else
      ProjectNukeCoreGUIHandler.AddButton("Menu" .. self.id .. "PageBack", self, "<", colours.white, colours.grey, x, y, 3, 1, self.actionPageBack, self.window)
    end

    -- Render the Forward Button
    if (self:getTotalPageCount() == self.currentPage) then
      ProjectNukeCoreGUIHandler.AddButton("Menu" .. self.id .. "PageForward", self, " ", colours.grey, colours.lightGrey, x + 6, y, 3, 1, nil, self.window)
    else
      ProjectNukeCoreGUIHandler.AddButton("Menu" .. self.id .. "PageForward", self, ">", colours.white, colours.grey, x + 6, y, 3, 1, self.actionPageForward, self.window)
    end
  
    -- Render the Page Number
    ProjectNukeCoreGUIHandler.AddButton("Menu" .. self.id .. "PageNumber", self, self.currentPage, colours.white, colours.lightGrey, x + 3, y, 3, 1, nil, self.window)
  end

  -- Render the Action Button, If Present
  if (self.actionButtonText ~= nil) then
    local actionButtonLength = (string.len(self.actionButtonText) + 2)
    ProjectNukeCoreGUIHandler.AddButton("Menu" .. self.id .. "PageActionButton", self, self.actionButtonText, colours.white, self.actionButtonColour, x + self.width - actionButtonLength + 1, y, actionButtonLength, 1, self.actionButtonFunction, self.window)
  end
end

function Menu.actionPageBack(clickableItem)
  menu = clickableItem.value

  menu.currentPage = menu.currentPage - 1
  menu:render()
end

function Menu.actionPageForward(clickableItem)
  menu = clickableItem.value

  menu.currentPage = menu.currentPage + 1
  menu:render()
end