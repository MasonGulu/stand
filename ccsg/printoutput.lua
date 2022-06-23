--- A widget that allows you to print data out.
-- @see widget
-- @module printoutput
local widget = require("ccsg.widget")

--- Defaults for the printoutput widget
-- @table printoutput
local printoutput = {
  type = "printoutput", -- string, used for gui packing/unpacking (must match filename without extension!)
  selectable = false, -- bool, disable interaction with this widget
}
-- Setup inheritence
setmetatable(printoutput, widget)
printoutput.__index = printoutput

--- Draw the printoutput widget.
function printoutput:draw()
  self:clear()
  self:drawFrame()
  for i = 1, self.textArea[2] do
    local preppedString = ""
    if self.value[i] then
      preppedString = self.value[i]:sub(1, self.size[1] - 2)
    end
    self:writeTextToLocalXY(preppedString, 1, self.textArea[2] + 1 - i)
  end
end

--- Scroll the printoutput widget.
function printoutput:scroll()
  for x = #self.value + 1, 2, -1 do
    self.value[x] = self.value[x - 1]
  end
  self.value[1] = ""
end

--- Print whatever is provided to the printoutput widget.
-- Scrolls before printing
-- @tparam any ...
function printoutput:print(...)
  str = ""
  for k, v in pairs(arg) do
    str = str.." "..tostring(k)
  end
  self:scroll()
  self.value[1] = str:sub(1, self.textArea[1])
  if str:len() > self.textArea[1] then
    self:print(str:sub(self.textArea[1] + 1, -1))
  end
end

--- Update size
-- @tparam int width
-- @tparam int height
function printoutput:updateSize(width, height)
  self.size = { width, height }
  self.textArea = { self.size[1] - 2, self.size[2] - 2 }
end

--- Create a new printoutput widget.
-- @tparam table pos {x,y}
-- @tparam table size {width,height}
-- @tparam[opt] table p
-- @treturn table printoutput
function printoutput.new(pos, size, p)
  local o = widget.new(nil, pos, size, p)
  setmetatable(o, printoutput)
  o.value = {}
  o.textArea = { o.size[1] - 2, o.size[2] }
  for i = 1, o.textArea[2] do
    o.value[i] = ""
  end
  o.selectable = false
  o:_applyParameters(p)
  return o
end

return printoutput
