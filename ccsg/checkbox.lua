--- A simple checkbox widget.
-- Inherits from the widget object.
-- @see widget
-- @module checkbox

local widget = require("ccsg.widget")

--- Defaults for the checkbox widget
-- @table checkbox
local checkbox = {
  type = "checkbox" -- string, used for gui packing/unpacking (must match filename without extension!)
}
-- Setup inheritence
setmetatable(checkbox, widget)
checkbox.__index = checkbox

--- Draw the checkbox widget.
function checkbox:draw()
  self:clear()
  self:drawFrame()
  if self.value then
    self:writeTextToLocalXY(string.char(7), 1, 1)
    -- closed checkbox
  else
    self:writeTextToLocalXY(string.char(186), 1, 1)
    -- open checkbox
  end
  local preppedString = self.text:sub(1, self.size[1] - 3)
  self:writeTextToLocalXY(preppedString, 2, 1)
end

--- Handle mouse_click events.
-- @tparam number mouseButton
-- @tparam number mouseX
-- @tparam number mouseY
-- @treturn boolean enable_events and state was changed
function checkbox:handleMouseClick(mouseButton, mouseX, mouseY)
  local x, y = self:convertGlobalXYToLocalXY(mouseX, mouseY)
  if x == 1 and y == 1 then
    self.value = not self.value
    return self.enable_events
  end
  return false
end

--- Handle key event
-- @tparam int keycode
-- @tparam bool held
-- @treturn bool space is pressed (state is changed) and enable_events
function checkbox:handleKey(keycode, held)
  if keycode == keys.space then
    self.value = not self.value
    return self.enable_events
  end
  return false
end

--- Create a new checkbox widget.
-- @tparam table pos {x,y}
-- @tparam table size {width,height}
-- @tparam string text single line string to display
-- @tparam[opt] table p
-- @treturn table checkbox
function checkbox.new(pos, size, text, p)
  local o = widget.new(nil, pos, size, p)
  setmetatable(o, checkbox)
  o.text = text
  o:_applyParameters(p)
  return o
end

return checkbox
