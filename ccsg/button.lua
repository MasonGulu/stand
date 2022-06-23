--- A simple button widget.
-- Inherits from the widget object.
-- @see widget
-- @module button
local widget = require("ccsg.widget")

--- Defaults for the button widget
-- @table button
local button = {
  type = "button", -- string, used for gui packing/unpacking (must match filename without extension!)
  enable_events = true, -- bool, events are enabled by default for buttons
}
-- Setup inheritence
setmetatable(button, widget)
button.__index = button

--- Draw the button widget.
function button:draw()
  self:clear()
  self:drawFrame()
  local preppedString = self.value:sub(1, self.size[1] - 2)
  self:writeTextToLocalXY(preppedString, 1, 1)
end

--- Handle mouse_click events
-- @tparam number mouseButton
-- @tparam number mouseX
-- @tparam number mouseY
-- @treturn boolean mouseclick is on button and enable_events
function button:handleMouseClick(mouseButton, mouseX, mouseY)
  local x, y = self:convertGlobalXYToLocalXY(mouseX, mouseY)
  if y > 0 and y < self.size[2] + 1 and x > 0 and x < self.size[1] - 1 then
    return self.enable_events
  end
  return false
end

--- Handle key events
-- @tparam int keycode
-- @tparam bool held
-- @treturn bool enter is pressed and enable_events
function button:handleKey(keycode, held)
  if keycode == keys.enter then
    -- enter
    return self.enable_events
  end
  return false
end

--- Update string or parameters
-- @tparam string string single line string to display
-- @tparam[opt] table p
function button:updateParameters(string, p)
  self.value = string
  self:_applyParameters(p)
end

--- Function called when updating the GUI theme
-- @tparam table theme
function button:updateTheme(theme)
  setmetatable(theme, widget.theme)
  local invertTheme = {internalInvert = true} -- this is required to ensure the internal colors of the button are inverted without modifying the table passed in
  theme.__index = theme -- (beyond adding an __index index)
  setmetatable(invertTheme, theme)
  self.theme = invertTheme
end

--- Create a new button widget.
-- @tparam table pos {x,y}
-- @tparam table size {width,height}
-- @tparam string string single line string to display
-- @tparam[opt] table p
-- @treturn table button
function button.new(pos, size, string, p)
  local o = widget.new(nil, pos, size, p)
  setmetatable(o, button)
  o.value = string
  o.theme = {internalInvert = true}
  setmetatable(o.theme, widget.theme) -- This is necessary because we modified the default theme table
  o:_applyParameters(p)
  return o
end

return button