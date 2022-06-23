local popup = require "ccsg.popup"
local modem = peripheral.find("modem")
assert(modem, "No modem found")
modem.open(38)

local gui = require("ccsg.gui")
local divider = require"ccsg.divider"
local text = require"ccsg.text"
local listbox = require"ccsg.listbox"
local button = require "ccsg.button"

local width, height = term.getSize()

local turtles = {{id=1,fuel=1000,isRunning=true,time=1000},{id=5,fuel=3000,isRunning=false,time=1000}}
local guiTurtles = {}
local guiTurtleLables = {}

local win = gui.new({
  divider.new({1,1}, {width,1},{top=true}),
  text.new({1,2},{width,1},string.format("ID |Fuel  |Active|Time")),
  turtleList = listbox.new({1,3},{width,height-7},{}),
  divider.new({1,height-4},{width,1}),
  stop = button.new({1,height-3},{math.floor(width/2),1},"Stop"),
  start = button.new({math.floor(width/2)+1,height-3},{math.floor(width/2),1},"Start"),
  divider.new({1,height-2},{width,1}),
  upload = button.new({1,height-1},{math.floor(width/2),1},"Upload"),
  refuel = button.new({math.floor(width/2)+1,height-1},{math.floor(width/2),1},"Refuel"),
  divider.new({1,height},{width,1},{bottom=true})
})

while true do
  local event, values, e = win:read()
  if e[1] == "modem_message" then
    local message = e[5]
    turtles[message.id] = message
  elseif event == "stop" then
    modem.transmit(37, 0, {"stop"})
  elseif event == "start" then
    modem.transmit(37, 0, {"start"})
  elseif event == "upload" then
    local filename = popup.fileBrowse(".lua", false, width-2, height-8)
    if filename then
      local f = fs.open(filename, "r")
      if f then
        modem.transmit(37, 0, {"download", f.readAll()})
      else
        popup.info("Error, file unable to be opened")
      end
    end
  elseif event == "refuel" then
    modem.transmit(37, 0, {"refuel"})
  end
  local line = 0
  for key, value in pairs(turtles) do
    -- win.write(string.format("[%2u] %5s %5u %s\n", key, value.isRunning, value.fuel, value.time))
    line = line + 1
    guiTurtles[line] = value.id
    guiTurtleLables[line] = string.format("%3u|%6u|%6s|%u",value.id,value.fuel,value.isRunning,value.time)
  end
  win.widgets.turtleList:updateParameters(guiTurtleLables, {minSelected=0,maxSelected=#guiTurtleLables})
end