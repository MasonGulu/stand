--- The main GUI handling object
-- @module gui

--- Default parameters for gui objects
-- @table gui
local gui = {
  disableBuffering = false, -- Boolean, disable dithering
  devMode = false, -- Boolean, devMode enables dragging widgets around and using middle click to gather information about the selected widget.
  device = term, -- Not implmented, GUIs can currently only be displayed on the terminal
  timeout = nil, -- Nil or number, set to enable timeouts
  autofit = false, -- Boolean, when enabled the gui will be centered in the middle of the terminal. This expects your gui to be anchored at 1,1.
}

-- Setup object oriented thing
gui.__index = gui

function gui:_draw()
  for key, v in pairs(self.widgets) do
    if v.enable then
      v.device.setVisible(self.disableBuffering)
      v:draw()
      v.device.setVisible(true)
    else
      v.device.setVisible(false)
    end
  end
  self.widgets[self.focusedWidget].device.setVisible(self.disableBuffering)
  self.widgets[self.focusedWidget]:draw() -- Double draw call, but whatever
  self.widgets[self.focusedWidget].device.setVisible(true)
end

function gui:_isXYonWidget(x, y, widget)
  if x >= widget.pos[1] and y >= widget.pos[2] and x < widget.pos[1] + widget.size[1] and y < widget.pos[2] + widget.size[2] then
    return true
  end
  return false
end

--- Read events from the gui.
-- @return string/number/nil key of element that threw an event
-- @treturn table Values of all elements in the gui, indexed by their index in the widget table
-- @treturn table event table {os.pullEvent()}
function gui:read()
  if self.completeRedraw then
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.clear()
    self.completeRedraw = false
  end
  self:_draw()
  local values = {}
  local timerID = -1
  if self.timeout then
    timerID = os.startTimer(self.timeout)
  end
  local event, a, b, c, d = os.pullEvent()
  os.cancelTimer(timerID)
  local eventn = false
  if event == "mouse_click" then
    if self.devMode and a == 3 then
      term.clear()
      term.setCursorPos(1, 1)
      print("The widget focused has")
      print("index", self.focusedWidget)
      print("x", self.widgets[self.focusedWidget].pos[1], "y", self.widgets[self.focusedWidget].pos[2])
      print("width", self.widgets[self.focusedWidget].size[1], "height", self.widgets[self.focusedWidget].size[2])
      print("type ", self.widgets[self.focusedWidget].type)
      print("Push enter to continue.")
      io.read()
      self.completeRedraw = true
    elseif self:_isXYonWidget(b, c, self.widgets[self.focusedWidget]) and self.widgets[self.focusedWidget].enable then
      if self.widgets[self.focusedWidget]:handleMouseClick(a, b, c, d) then eventn = self.focusedWidget end
    else
      for key, v in pairs(self.widgets) do
        if self:_isXYonWidget(b, c, v) and v.enable and (v.selectable or self.devMode) then
          self.widgets[self.focusedWidget]:setFocus(false)
          self.focusedWidget = key
          v:setFocus(true)
          if v:handleMouseClick(a, b, c, d) then eventn = key end
          break
        end
      end
    end
  elseif event == "key" then
    if a == keys.tab then
      self.selectedWidgetIndex = self.selectedWidgetIndex + 1
      if self.selectedWidgetIndex > #self.selectableWidgetKeys then
        self.selectedWidgetIndex = 1
      end
      self.widgets[self.focusedWidget]:setFocus(false)
      self.focusedWidget = self.selectableWidgetKeys[self.selectedWidgetIndex]
      self.widgets[self.focusedWidget]:setFocus(true)

    else
      if self.widgets[self.focusedWidget]:handleKey(a, b, c, d) then eventn = self.focusedWidget end
    end
  elseif event == "mouse_scroll" then
    if self.widgets[self.focusedWidget]:handleMouseScroll(a, b, c) then eventn = self.focusedWidget end
  elseif event == "char" then
    if self.widgets[self.focusedWidget]:handleChar(a, b, c, d) then eventn = self.focusedWidget end
  elseif event == "paste" then
    if self.widgets[self.focusedWidget]:handlePaste(a) then eventn = self.focusedWidget end
  elseif event == "mouse_drag" then
    if self.devMode then
      if a == 1 then
        -- left click, move
        self.widgets[self.focusedWidget]:updatePos(b, c)
        self.completeRedraw = true
      elseif a == 2 then
        -- right click, resize
        local pos = self.widgets[self.focusedWidget].pos
        local newWidth, newHeight = self.widgets[self.focusedWidget].size[1], self.widgets[self.focusedWidget].size[2]
        if b - pos[1] > 3 then newWidth = b - pos[1] + 1 else newWidth = 3 end
        if c - pos[2] > 1 then newHeight = c - pos[2] + 1 else newHeight = 1 end
        self.widgets[self.focusedWidget]:updateSize(newWidth, newHeight)
        self.completeRedraw = true
      end
    end
  elseif event == "term_resize" and self.autofit then
    self:doAutofit()
  end
  for key, v in pairs(self.widgets) do
    values[key] = v:getValue()
  end
  return eventn, values, { event, a, b, c, d }
end

function gui:doAutofit()
  local yMax = 0
  local xMax = 0
  local yMin = math.huge
  local xMin = math.huge
  for key, value in pairs(self.widgets) do
    local xPos, yPos = table.unpack(value.pos)
    local width, height = table.unpack(value.size)
    yMax = math.max(yPos + height, yMax)
    yMin = math.min(yPos, yMin)
    xMax = math.max(xPos + width, xMax)
    xMin = math.min(xPos, xMin)
  end
  local width, height = self.device.getSize()
  local guiWidth = xMax - xMin + 1
  local guiHeight = yMax - yMin + 1
  local startingYPos = math.ceil((height - guiHeight) / 2) - yMin + 1
  local startingXPos = math.ceil((width - guiWidth) / 2) - xMin + 1
  for key, value in pairs(self.widgets) do
    value:updatePos(value.pos[1] + startingXPos, value.pos[2] + startingYPos)
  end
  self.completeRedraw = true
end

--- Create a new gui object
-- @tparam table widgets widget table
-- @tparam[opt] table parameters
function gui.new(widgets, parameters)
  local o = {}
  setmetatable(o, gui)
  o.widgets = widgets
  o.selectableWidgetKeys = {}
  for key, value in pairs(o.widgets) do
    if value.selectable then
      o.selectableWidgetKeys[#o.selectableWidgetKeys+1] = key
    end
  end
  if #o.selectableWidgetKeys == 0 then
    error("Widgets must contain at least one selectable widget!")
  end
  o.selectedWidgetIndex = 1
  local widgetKey = o.selectableWidgetKeys[1]
  o.widgets[widgetKey]:setFocus(true)
  o.focusedWidget = widgetKey
  o.completeRedraw = true

  if type(parameters) == "table" then
    for key, value in pairs(parameters) do
      o[key] = value
    end
    if parameters.theme then
      for key, value in pairs(o.widgets) do
        value:updateTheme(parameters.theme)
      end
    end
  end

  if o.autofit then
    o:doAutofit()
  end

  return o
end

return gui
