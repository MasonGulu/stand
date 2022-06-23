--- A visual divider that has no additional functionality
-- Inherits from the widget object.
-- @see widget
-- @module divider
local widget = require("ccsg.widget")

--- Defaults for the divider widget
-- @table divider
local divider = {
  type = "divider", -- string, used for gui packing/unpacking (must match filename without extension!)
  selectable = false, -- bool, disable interaction with this widget.
  modifyWalls = true, -- bool, whether to modify the walls from the default
  top = false, -- bool, whether this divider is the top (requires modifyWalls)
  bottom = false, -- bool, whether this divider is the bottom (requires modifyWalls)
}
-- Setup inheritence
setmetatable(divider, widget)
divider.__index = divider

--- Draw the divider widget.
function divider:draw()
  self:clear()
  self:drawFrame()
  self.device.setCursorPos(2,1)
  self:setFrameColor()
  self.device.write(self.value)
  self:setPreviousColor()
  if self.modifyWalls then
    if self.top then
      self:setFrameColor(self.theme.invertTopLeft)
      self.device.setCursorPos(1, 1)
      self.device.write(self.theme.topLeftWall)
      self:setPreviousColor()
      self:setFrameColor(self.theme.invertTopRight)
      self.device.setCursorPos(self.size[1], 1)
      self.device.write(self.theme.topRightWall)
      self:setPreviousColor()
    elseif self.bottom then
      self:setFrameColor(self.theme.invertBottomLeft)
      self.device.setCursorPos(1, 1)
      self.device.write(self.theme.bottomLeftWall)
      self:setPreviousColor()
      self:setFrameColor(self.theme.invertBottomRight)
      self.device.setCursorPos(self.size[1], 1)
      self.device.write(self.theme.bottomRightWall)
      self:setPreviousColor()
    else
      self:setFrameColor(self.theme.invertCenterLeft)
      self.device.setCursorPos(1, 1)
      self.device.write(self.theme.centerLeftWall)
      self:setPreviousColor()
      self:setFrameColor(self.theme.invertCenterRight)
      self.device.setCursorPos(self.size[1], 1)
      self.device.write(self.theme.centerRightWall)
      self:setPreviousColor()
    end
  end
end

--- Function called to update the size of the widget.
-- @tparam int width
-- @tparam int height
function divider:updateSize(width, height)
  self.value = string.rep(string.char(140), width - 2)
  widget.updateSize(self, width, height)
end

--- Create a new divider widget.
-- @tparam table pos {x,y}
-- @tparam table size {width,height}
-- @tparam[opt] table p
-- @treturn table divider
function divider.new(pos, size, p)
  local o = widget.new(nil, pos, size, p)
  setmetatable(o, divider)
  o.value = string.rep(string.char(140), o.size[1] - 2)
  o:_applyParameters(p)
  return o
end

return divider
