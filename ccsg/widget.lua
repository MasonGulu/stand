--- The base widget object.
-- @module widget
local expect = require("cc.expect")


--- Default widget parameters
-- @table widget
local widget = {
  focused = false, -- bool, is the widget focused?
  value = "", -- String, the data contained in the widget, sometimes other types
  enable_events = false, -- bool, if this widget should throw events
  device = term, -- Device the widget is displayed on, not implemented currently. do not change.
  enable = true, -- bool, render and process events
  frame = true, -- bool, draw frame around widget
  selectable = true, -- bool, should this object be selectable?
  theme = {}, -- table, theme information
  type = "widget", -- string, name of file / widget type
}

widget.__index = widget

--- Default widget theme, table is contents of widget.theme
-- @table widget.theme
widget.theme = {
  wallLeft = string.char(149), -- char, character used for left side vertical widget walls
  wallRight = string.char(149), -- char, character used for right side vertical widget walls
  wallLeftInvert = false, -- should fg/bg colors be swapped for wallLeft
  wallRightInvert = true, -- should fg/bg colors be swapped for wallRight
  wallLeftFocused = string.char(16), -- char, character used for left side widget walls when focused
  wallRightFocused = string.char(17), -- char, character used for right side widget walls when focused
  wallLeftFocusedInvert = false, -- should fg/bg colors be swapped for wallLeft
  wallRightFocusedInvert = false, -- should fg/bg colors be swapped for wallRight
  frameFG = colors.white, -- color, text color of frame
  frameBG = colors.black, -- color, background color of frame
  internalFG = colors.white, -- color, text color of internal widget
  internalBG = colors.black, -- color, text color of internal widget
  internalInvert = false, -- should fg/bg colors be swapped for internals
  topRightWall = string.char(147), -- char, character used for divider top right wall
  invertTopRight = true, -- bool, invert divider top right wall fg/bg
  topLeftWall = string.char(156), -- char, character used for divider top left wall
  invertTopLeft = false, -- bool, invert divider top left wall fg/bg
  bottomRightWall = string.char(142), -- char, character used for divider bottom right wall
  invertBottomRight = false, -- bool, invert divider bottom right wall fg/bg
  bottomLeftWall = string.char(141), -- char, character used for divider bottom left wall
  invertBottomLeft = false, -- bool, invert divider bottom left wall fg/bg
  centerLeftWall = string.char(157), -- char, character used for divider center left wall
  invertCenterLeft = false, -- bool, invert divider center left wall fg/bg
  centerRightWall = string.char(145), -- char, character used for divider center right wall
  invertCenterRight = true, -- bool, invert divider center right wall fg/bg
}

widget.theme.__index = widget.theme

--- Draw a character repeated vertically
-- @tparam string char
-- @tparam int x
-- @tparam int height
function widget:_drawCharacterVertically(char, x, height)
  expect(1, char, "string")
  expect(2, x, "number")
  expect(3, height, "number")
  for y = 1, height do
    self.device.setCursorPos(x, y)
    self.device.write(char)
  end
end

--- Draw the frame of the widget.
-- Applies theme colors
function widget:drawFrame()
  if self.frame then
    if self.focused then
      self:setFrameColor(self.theme.wallLeftFocusedInvert)
      self:_drawCharacterVertically(self.theme.wallLeftFocused, 1, self.size[2])
      self:setPreviousColor()
      self:setFrameColor(self.theme.wallRightFocusedInvert)
      self:_drawCharacterVertically(self.theme.wallRightFocused, self.size[1], self.size[2])
    else
      self:setFrameColor(self.theme.wallLeftInvert)
      self:_drawCharacterVertically(self.theme.wallLeft, 1, self.size[2])
      self:setPreviousColor()
      self:setFrameColor(self.theme.wallRightInvert)
      self:_drawCharacterVertically(self.theme.wallRight, self.size[1], self.size[2])
    end
  end
  self:setPreviousColor()
end

--- Draw the internal area of the widget.
-- Applies theme colors and reverts.
function widget:draw()
  self:clear()
  self:drawFrame()
end

--- Clear the internal area of the widget.
-- Applies theme colors and reverts.
function widget:clear(FG, BG)
  self:setInternalColor(self.theme.internalInvert, FG, BG)
  self.device.clear()
  self:setPreviousColor()
end

--- Convert from device X,Y space to local X,Y space with 1,1 being the top left corner of the widget (inside the frame!)
-- @tparam int x device X
-- @tparam int y device y
-- @treturn int local X
-- @treturn int local Y
function widget:convertGlobalXYToLocalXY(x, y)
  expect(1, x, "number")
  expect(2, y, "number")
  return x - self.pos[1], y - self.pos[2] + 1
end

--- Convert from local X,Y space to device X,Y space
-- @tparam int x local x
-- @tparam int y local y
-- @treturn int device x
-- @treturn int device y
function widget:convertLocalXYToGlobalXY(x, y)
  expect(1, x, "number")
  expect(2, y, "number")
  return x + self.pos[1], y + self.pos[2]
end

--- Set the focus state of the widget, basically just sets the object's focused flag and draws the corners with the corrosponding characters.
-- Applies theme colors.
-- @tparam bool focus
function widget:setFocus(focus)
  expect(1, focus, "boolean")
  self.focused = focus
  self:drawFrame()
end

--- Event handler function called when a mouse_click event occurs on the widget.
-- @tparam int mouseButton
-- @tparam int mouseX global X
-- @tparam int mouseY global Y
-- @treturn bool this widget wants to notify an event occured
function widget:handleMouseClick(mouseButton, mouseX, mouseY)
  local x, y = self:convertGlobalXYToLocalXY(mouseX, mouseY)
  return false
end

--- Event handler function called when a key event occurs with the widget focused.
-- @tparam int keycode
-- @tparam int held
-- @treturn bool this widget wants to notify an event occured
function widget:handleKey(keycode, held)
  return false
end

--- Event handler function called when a mouse_scroll event occurs with the widget focused
-- @tparam int direction
-- @tparam int mouseX global X
-- @tparam int mouseY global Y
-- @treturn bool this widget wants to notify an event occured
function widget:handleMouseScroll(direction, mouseX, mouseY)
  return false
end

--- Event handler function called when a paste event occurs with the widget focused
-- @tparam string text
-- @treturn bool this widget wants to notify an event occured
function widget:handlePaste(text)
  return false
end

--- Event handler function called when a char event occurs with the widget focused.
-- @tparam character char
-- @treturn bool this widget wants to notify an event occured
function widget:handleChar(char)
  return false
end

--- Event handler for any other events that aren't covered by the other handles
-- @tparam table e event table {os.pullEvent()}
-- @treturn bool this widget wants to notify an event occured
function widget:otherEvent(e)
  return false
end

--- Function called to update the position of the widget.
-- @tparam int x
-- @tparam int y
function widget:updatePos(x, y)
  expect(1, x, "number")
  expect(2, y, "number")
  self.pos = { x, y }
  self.device.reposition(x, y)
end

--- Function called to update the size of the widget.
-- @tparam int width
-- @tparam int height
function widget:updateSize(width, height)
  expect(1, width, "number")
  expect(2, height, "number")
  self.size = { width, height }
  self.device.reposition(self.pos[1], self.pos[2], width, height)
end

--- Function to set the term colors according to the internal color theme
-- Remembers previous colors to allow reverting
-- @tparam[opt] bool invert
-- @param[optchain] FG
-- @param[optchain] BG
function widget:setInternalColor(invert, FG, BG)
  self.previousBG = self.device.getBackgroundColor()
  self.previousFG = self.device.getTextColor()
  if invert then
    self.device.setBackgroundColor(FG or self.theme.internalFG)
    self.device.setTextColor(BG or self.theme.internalBG)
  else
    self.device.setBackgroundColor(BG or self.theme.internalBG)
    self.device.setTextColor(FG or self.theme.internalFG)
  end
end

--- Function to set the term colors according to the frame color theme
-- Remembers previous colors to allow reverting
-- @tparam[opt] bool invert
function widget:setFrameColor(invert)
  self.previousBG = self.device.getBackgroundColor()
  self.previousFG = self.device.getTextColor()
  if invert then
    self.device.setBackgroundColor(self.theme.frameFG)
    self.device.setTextColor(self.theme.frameBG)
  else
    self.device.setBackgroundColor(self.theme.frameBG)
    self.device.setTextColor(self.theme.frameFG)
  end

end

--- Reverts colors to what they were previously
function widget:setPreviousColor()
  self.device.setBackgroundColor(self.previousBG)
  self.device.setTextColor(self.previousFG)
end

--- Writes text to a relative X,Y position in the widget.
--- Relative X,Y as in offset by + 1 on the X axis because of the left/right walls
-- @param text
-- @tparam int x local X
-- @tparam int y local y
function widget:writeTextToLocalXY(text, x, y)
  expect(2, x, "number")
  expect(3, y, "number")
  self.device.setCursorPos(x + 1, y)
  self:setInternalColor(self.theme.internalInvert)
  self.device.write(text)
  self:setPreviousColor()
end

--- This function should be overwritten to allow changing conditions as if they were set in the new() function
-- @tparam[opt] table p
function widget:updateParameters(p)
  self:_applyParameters(p)
end

--- This function returns the "value" of the widget
function widget:getValue()
  return self.value
end

--- Create a new widget object.
-- @tparam table o original object
-- @tparam table pos table {x: int,y: int}
-- @tparam table size table {width: int, height: int}
-- @tparam[opt] table p
-- @treturn table widget object
function widget.new(o, pos, size, p)
  o = o or {}
  setmetatable(o, widget)
  o.pos = pos
  o.size = size
  o.theme = {}
  setmetatable(o.theme, widget.theme)
  o.device = window.create(term.current(), o.pos[1], o.pos[2], o.size[1], o.size[2])
  return o
end

--- Function called when updating the GUI theme
-- @tparam table theme
function widget:updateTheme(theme)
  setmetatable(theme, widget.theme)
  self.theme = theme
end

--- Apply parameters to this widget
-- @tparam[opt] table p
function widget:_applyParameters(p)
  if type(p) == "table" then
    for key, value in pairs(p) do
      if key == "device" then
        self.device = window.create(value, self.pos[1], self.pos[2], self.size[1], self.size[2])
      else
        self[key] = value
      end
    end
  end
end

return widget
