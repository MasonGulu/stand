--- A collection of premade popups for you to use in your program

local gui = require("ccsg.gui")
local popup = {}

--- Get input from the user
-- @tparam string message
-- @tparam[opt] int width
-- @return[1] false if the user cancelled
-- @treturn[2] string input
function popup.getInput(message, width)
  term.clear()
  local wWidth, wHeight = term.getSize()
  width = width or 25

  local text = require("ccsg.text")
  local textinput = require("ccsg.textinput")
  local button = require("ccsg.button")
  local divider = require("ccsg.divider")
  local win = gui.new({
    divider.new({ 1, 1 }, { width, 1 }, { top = true }),
    text.new({ 1, 2 }, { width, 1 }, message),
    input = textinput.new({ 1, 3 }, { width, 1 }),
    cancelButton = button.new({ 1, 4 }, { math.floor(width / 2), 1 }, "Cancel"),
    submitButton = button.new({ 1 + math.ceil(width / 2), 4 }, { math.floor(width / 2), 1 }, "Submit"),
    divider.new({ 1, 5 }, { width, 1 }, { bottom = true })
  }, {autofit=true})
  while true do
    local event, values = win:read()
    if event == "cancelButton" then
      return false
    elseif event == "submitButton" then
      if string.len(values.input) > 0 then
        return values.input
      end
    end
  end
end

--- Have the user select an element from a list of string capable objects
-- @tparam string message
-- @tparam table list
-- @tparam[opt] int width
-- @return[1] false if user cancelled
-- @return[2] value from table selected
-- @treturn[2] int index of table selected
function popup.pickFromList(message, list, width)
  term.clear()
  local text = require("ccsg.text")
  local listbox = require("ccsg.listbox")
  local button = require("ccsg.button")
  local divider = require("ccsg.divider")

  width = width or 20

  local buttonWidth = math.floor(width / 2)

  local win = gui.new({
    divider.new({ 1, 1 }, { width, 1 }, { top = true }),
    text.new({ 1, 2 }, { width, 2 }, message),
    listbox = listbox.new({ 1, 4 }, { width, 5 }, list),
    text.new({ 1, 9 }, { width, 1 }, ""),
    cancelButton = button.new({ 1, 10 }, { buttonWidth, 1 }, "Cancel"),
    submitButton = button.new({ buttonWidth + 1, 10 }, { buttonWidth, 1 }, "Submit"),
    divider.new({ 1, 11 }, { width, 1 }, { bottom = true })
  }, { autofit = true })
  while true do
    local winEvent, values = win:read()
    if winEvent == "cancelButton" then
      return false
    elseif winEvent == "submitButton" then
      return list[values.listbox], values.listbox
    end
  end
end

local function getFoldersAndFiles(directory, fileExtension)
  local allList = fs.list(directory)
  local dirList = {}
  if directory ~= "/" and directory ~= "" then
    dirList[1] = ".."
  end
  local fileList = {}
  for key, value in ipairs(allList) do
    if fs.isDir(fs.combine(directory, value)) then
      table.insert(dirList, value .. '/')
    else
      if fileExtension then
        if string.sub(value, -string.len(fileExtension), -1) == fileExtension then
          table.insert(fileList, value)
        end
      else
        table.insert(fileList, value)
      end
    end
  end
  return dirList, fileList
end

-- adapted from https://stackoverflow.com/a/15278426
local function tableConcat(t1, t2)
  local t3 = {}
  for i = 1, #t1 do
    t3[i] = t1[i]
  end
  for i = 1, #t2 do
    t3[#t3 + 1] = t2[i]
  end
  return t3
end

--- Show a file picker
-- @tparam[opt] string fileExtension i.e. ".bimg"
-- @tparam[optchain] bool write warn before overwriting files
-- @tparam[optchain] int width default 25
-- @tparam[optchain] int height default 5; height of listbox
-- @return[1] false if user cancelled
-- @treturn[2] string path
function popup.fileBrowse(fileExtension, write, width, height)
  -- file extension is expected to contain dot ie ".scd"
  term.clear()
  local wWidth, wHeight = term.getSize()
  width = width or 25
  height = height or 5
  if type(write) == "nil" then
    write = false
  end
  local buttonWidth = math.floor(width / 2)

  local text = require("ccsg.text")
  local button = require("ccsg.button")
  local listbox = require("ccsg.listbox")
  local divider = require("ccsg.divider")
  local textinput = require("ccsg.textinput")

  local widgets = {
    divider.new({ 1, 1 }, { width, 1 }, { top = true }),
    directoryLabel = text.new({ 1, 2 }, { width - 9, 1 }, "/"),
    directoryAddButton = button.new({ width - 8, 2 }, { 9, 1 }, "New Dir"),
    divider.new({ 1, 3 }, { width, 1 }),
    directoryListbox = listbox.new({ 1, 4 }, { width, height }, { "example" }),
    divider.new({ 1, height + 4 }, { width, 1 }),
    divider.new({ 1, height + 6 }, { width, 1 }),
    cancelButton = button.new({ 1, height + 7 }, { buttonWidth + 1, 1 }, "Cancel"),
    selectButton = button.new({ buttonWidth + 2, height + 7 }, { buttonWidth, 1 }, "Submit"),
    divider.new({ 1, 1 + height + 7 }, { width, 1 }, { bottom = true })
  }
  
  if fileExtension then
    widgets.filenameInput = textinput.new({ 1, height + 5 }, { width - 6, 1 })
    widgets[#widgets+1] = text.new({ 1 + width - 6, height + 5 }, { 6, 1 }, fileExtension)
  else
    widgets.filenameInput = textinput.new({ 1, height + 5 }, { width, 1 })
  end
  local win = gui.new(widgets, {autofit=true})

  local dirChanged = true -- whether to recalculate the current directory
  local currentDir = "/"

  local dirList, fileList

  while true do
    if dirChanged then
      dirList, fileList = getFoldersAndFiles(currentDir, fileExtension)
      win.widgets.directoryListbox:updateParameters(tableConcat(dirList, fileList))
      win.widgets.directoryLabel:updateParameters(currentDir)
      dirChanged = false
    end
    local event, values = win:read()
    if event == "directoryListbox" then
      -- directory changed or file selected
      if values.directoryListbox[1] > #dirList then
        -- this is a file
        widgets.filenameInput:updateParameters({ value = fileList[values.directoryListbox[1] - #dirList]})
      else
        -- this is a folder
        dirChanged = true
        currentDir = fs.combine(currentDir, dirList[values.directoryListbox[1]])
      end

    elseif event == "selectButton" then
      local returnFilename
      if fileExtension then
        returnFilename = currentDir .. values.filenameInput
        if (returnFilename:sub(-fileExtension:len(), -1) ~= fileExtension) then
          returnFilename = returnFilename..fileExtension
        end
      else
        returnFilename = currentDir .. values.filenameInput
      end
      
      if write and fs.exists(returnFilename) then
        -- give warning about overwriting a file
        if popup.confirm("Overwrite " .. returnFilename .. "?") then
          return returnFilename
        end
      else
        return returnFilename
      end

    elseif event == "cancelButton" then
      return false

    elseif event == "directoryAddButton" then
      local newDirName = popup.getInput("Enter new directory name:", 27)
      if newDirName then
        fs.makeDir(fs.combine(currentDir, newDirName))
        dirChanged = true
      end

    end
  end
end

--- Show a popup with some info on it
-- @param message
-- @param[opt] buttonLabel
-- @tparam[optchain] int width
-- @tparam[optchain] int height height of textbox
function popup.info(message, buttonLabel, width, height)
  local wWidth, wHeight = term.getSize()
  width = width or 25
  height = height or 3
  local text = require("ccsg.text")
  local button = require("ccsg.button")
  local divider = require("ccsg.divider")
  buttonLabel = buttonLabel or "Close"
  local win = gui.new({
    divider.new({ 1, 1 }, { width, 1 }, { top = true }),
    text.new({ 1, 2 }, { width, height }, message),
    ackButton = button.new({ 1, 2 + height }, { width, 1 }, buttonLabel),
    divider.new({ 1, 3 + height }, { width, 1 }, { bottom = true })
  },{autofit=true})
  local event, values
  repeat
    event, values = win:read()
  until event == "ackButton"
  term.clear()
end

--- Show a popup asking the user to confirm
-- @param message
-- @tparam[opt] int height
-- @tparam[optchain] int width
-- @treturn boolean user confirmed
function popup.confirm(message, height, width)
  local wWidth, wHeight = term.getSize()
  width = width or 25
  height = height or 3

  local buttonWidth = math.floor(width / 2)
  local text = require("ccsg.text")
  local button = require("ccsg.button")
  local divider = require("ccsg.divider")
  local win = gui.new({
    divider.new({ 1, 1 }, { width, 1 }, { top = true }),
    text.new({ 1, 2 }, { width, height }, message),
    noButton = button.new({ 1, 2 + height }, { buttonWidth, 1 }, "No"),
    yesButton = button.new({ 1 + buttonWidth + 1, 2 + height }, { buttonWidth, 1 }, "Yes"),
    divider.new({ 1, 3 + height }, { width, 1 }, { bottom = true })
  }, {autofit=true})
  local event, values
  repeat
    event, values = win:read()
  until event == "yesButton" or event == "noButton"
  term.clear()
  return event == "yesButton"
end

--- Show a popup to edit a table.
-- Each value in the table can be replaced with a value of the same type
-- @tparam table T
-- @param textString label
-- @tparam[opt] int textHeight
-- @tparam[optchain] int keyWidth
-- @tparam[optchain] int valueWidth
-- @treturn table modified T
function popup.editT(T, textString, textHeight, keyWidth, valueWidth)
  keyWidth = keyWidth or 5
  valueWidth = valueWidth or 12
  textHeight = textHeight or 3
  local width = keyWidth + valueWidth
  local wWidth, wHeight = term.getSize()

  local text = require("ccsg.text")
  local button = require("ccsg.button")
  local divider = require("ccsg.divider")
  local textinput = require("ccsg.textinput")
  local checkbox = require("ccsg.checkbox")

  local widgets = {
    DIV1 = divider.new({ 1, 1 }, { width, 1 }, { top = true }),
    TXT1 = text.new({ 1, 2 }, { width, textHeight }, textString),
    DIV2 = divider.new({ 1, textHeight + 2 }, { width, 1 })
  }
  local offset = textHeight + 2 -- offset from ypos
  for key, value in pairs(T) do
    if keyWidth > 0 then
      widgets["DIV" .. tostring(offset)] = text.new({ 1, 1 + offset }, { keyWidth, 1 }, key)
    end
    if type(value) == "boolean" then
      widgets[key] = checkbox.new({ 1 + keyWidth, 1 + offset }, { valueWidth, 1 }, tostring(key), { value = value })
    elseif type(value) == "number" then
      widgets[key] = textinput.new({ 1 + keyWidth, 1 + offset }, { valueWidth, 1 }, { numOnly = true, value = value })
    elseif type(value) == "table" then
      widgets[key] = button.new({ 1 + keyWidth, 1 + offset }, { valueWidth, 1 }, "TABLE")
    elseif type(value) == "string" then
      widgets[key] = textinput.new({ 1 + keyWidth, 1 + offset }, { valueWidth, 1 }, { value = value })
    end
    offset = offset + 1
  end
  widgets.DIV3 = divider.new({ 1, 1 + offset }, { width, 1 })
  widgets.ackButton = button.new({ 1, offset + 2 }, { width, 1 }, "Submit")
  widgets.DIV4 = divider.new({ 1, offset + 3 }, { width, 1 }, { bottom = true })
  local win = gui.new(widgets, { autofit=true})
  local event, values
  repeat
    event, values = win:read()
    if type(T[event]) == "table" then
      T[event] = popup.editT(T[event], textString, textHeight, keyWidth, valueWidth)
    end
  until event == "ackButton"
  for key, _ in pairs(T) do
    T[key] = values[key]
  end
  term.clear()
  return T
end

return popup
