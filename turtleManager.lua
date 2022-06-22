local modem = peripheral.wrap("back")
modem.open(38)

local turtles = {}

local width, height = term.getSize()
local win = window.create(term.current(), 1, 1, width, height)

while true do
    win.setVisible(false)
    win.clear()
    
    local line = 1
    for key, value in pairs(turtles) do
        win.setCursorPos(1,line)
        win.write(string.format("[%2u] %5s %5u %s\n", key, value.isRunning, value.fuel, value.time))
        line = line + 1
    end
    win.setCursorPos(1,17)
    win.write(string.format("<%11s><%11s>\n", "START", "STOP"))
    win.setCursorPos(1,18)
    win.write("<UPLOAD>")
    win.setCursorPos(1,19)
    win.write("<REFUEL>")
    win.setVisible(true)
    local event, message, x, y
    repeat
        event, _, x, y, message, _ = os.pullEvent()
    until event == "modem_message" or event == "mouse_click"
    if event == "modem_message" then
       turtles[message.id] = message
       
       
    elseif event == "mouse_click" then
        if y == 17 then
            if x < 11 then
                modem.transmit(37, 0, {"start"})
            else
                modem.transmit(37, 0, {"stop"})
            end
            
            
        elseif y == 18 then
            win.clear()
            win.setCursorPos(1,1)
            for key, value in pairs(fs.list("/")) do
                print(value)
            end
            print("Enter a filename")
            local filename = io.read()
            if filename ~= "" then
                local f = fs.open(filename, "r")
                if f then
                    modem.transmit(37, 0, {"download", f.readAll()})
                else
                    print("Error, file unable to be opened")
                    sleep(1)
                end
            end
        elseif y == 19 then
            modem.transmit(37, 0, {"refuel"})
        end
    end
end