--- A text displaying widget.
-- Text is autowrapped to fit into the area of the widget.
-- Inherits from the widget object.
-- @see widget
-- @module text
local widget = require("ccsg.widget")

--- Defaults for the text widget
-- @table text
local text = {
  type = "text",-- string, used for gui packing/unpacking (must match filename without extension!)
  selectable = false, -- bool, disable interaction with this widget
}
-- Setup inheritence
setmetatable(text, widget)
text.__index = text

--- Draw the text widget.
function text:draw()
  self:clear()
  self:drawFrame()
  for i = 1, self.textArea[2] do
    local preppedString = self.value[i]:sub(1, self.size[1] - 2)
    self:writeTextToLocalXY(preppedString, 1, self.textArea[2] + 1 - i)
  end
end


function text:scrollTextArray()
  for x = self.textArea[2] + 1, 2, -1 do
    self.value[x] = self.value[x - 1]
  end
  self.value[1] = ""
end

function text:formatStringToFitWidth(str)
  str = tostring(str)
  self:scrollTextArray()
  self.value[1] = str:sub(1, self.textArea[1])
  if str:len() > self.textArea[1] then
    self:formatStringToFitWidth(str:sub(self.textArea[1] + 1, -1))
  end
end

--- Update size of text widget
-- @tparam int width
-- @tparam int height
function text:updateSize(width, height)
  widget.updateSize(self, width, height)
  self.textArea = { self.size[1] - 2, self.size[2] }
  for i = 1, self.textArea[2] do
    self.value[i] = ""
  end
  self:formatStringToFitWidth(self.string)
end

--- Update parameters
-- @tparam string string
-- @tparam[opt] table p
function text:updateParameters(string, p)
  self.string = string
  self:formatStringToFitWidth(self.string)
  self:_applyParameters(p)
end

--- Create a new text widget.
-- @tparam table pos {x,y}
-- @tparam table size {width,height}
-- @tparam string string
-- @tparam[opt] table p
-- @treturn table text object
function text.new(pos, size, string, p)
  local o = widget.new(nil, pos, size, p)
  setmetatable(o, text)
  o.value = {}
  o.textArea = { o.size[1] - 2, o.size[2] }
  for i = 1, o.textArea[2] do
    o.value[i] = ""
  end
  o.string = string
  o:formatStringToFitWidth(o.string)
  o:_applyParameters(p)
  return o
end

return text
