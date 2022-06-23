--- A textinput widget.
-- value is the text input, if in numOnly then the value is converted to a number first.
-- Inherits from the widget object.
-- @see widget
-- @module textinput
local widget = require("ccsg.widget")

--- Defaults for the textinput widget
-- @table textinput
local textinput = {
  type = "textinput", -- string, used for gui packing/unpacking (must match filename without extension!)
  default = 0, -- number, default value if numOnly textinput is empty
  numOnly = false, -- bool, only accept numbers
  hasDecimal = false, -- bool, internal value but if set to true can prevent users from inputing non-integer numbers
  hideInput = false, -- bool, whether to hide the input or not
  enable_events = true, -- bool, events are enabled by default
}
-- Setup inheritence
setmetatable(textinput, widget)
textinput.__index = textinput

--- Draw the textinput widget
function textinput:draw()
  self:clear()
  self:drawFrame()
  if self.hideInput then
    self:writeTextToLocalXY('\7', 1, 1)
    self:writeTextToLocalXY(string.rep("*", string.len(self.value)), 2, 1)
  else
    if self.numOnly then
      self:writeTextToLocalXY('#', 1, 1)
    else
      self:writeTextToLocalXY('?', 1, 1)
    end
    self:writeTextToLocalXY(self.value, 2, 1)
  end
end

--- Handle key events
-- @tparam int keycode
-- @tparam bool held
-- @treturn bool enter is pressed and enable_events
function textinput:handleKey(keycode, held)
  if keycode == keys.backspace then
    -- backspace
    self.hasDecimal = self.hasDecimal and tostring(self.value):sub(-1, -1) ~= '.'
    self.value = tostring(self.value):sub(1, -2)
  elseif keycode == keys.enter then
    -- enter
    return self.enable_events
  end
  return false
end

--- Handle char events
-- @tparam string char
-- @treturn bool false
function textinput:handleChar(char)
  if self.numOnly then
    if (char >= '0' and char <= '9') or (char == '.' and not self.hasDecimal) then
      if string.len(self.value) < self.maxTextLen then
        self.hasDecimal = self.hasDecimal or char == '.'
        self.value = self.value .. char
      end
    end
  else
    if string.len(self.value) < self.maxTextLen then
      self.value = self.value .. char
    end
  end
  return false
end

--- Update size of widget
-- @tparam int width
-- @tparam int height
function textinput:updateSize(width, height)
  widget.updateSize(self, width, height)
  self.maxTextLen = self.size[1] - 3
end

--- Get textinput's value
-- @treturn[1] string !numOnly
-- @treturn[2] number numOnly
function textinput:getValue()
  if self.numOnly and self.value == "" then
    return self.default
  elseif self.numOnly then
    return tonumber(self.value)
  end
  return self.value
end

-- function textinput:updateParameters(p)
--   self:_applyParameters(p)
-- end

--- Create a new textinput widget
-- @tparam table pos {x,y}
-- @tparam table size {width,height}
-- @tparam[opt] table p
-- @treturn table textinput
function textinput.new(pos, size, p)
  local o = widget.new(nil, pos, size, p)
  setmetatable(o, textinput)
  o.value = ""
  o.maxTextLen = o.size[1] - 3
  o.hasDecimal = false
  o:_applyParameters(p)
  return o
end

return textinput
