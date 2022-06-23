local modem = peripheral.wrap("right")
modem.open(37)

local isRunning = false
local event, _, _, _, message, _
local turtleProgram
while true do
    local timerId = os.startTimer(0.5)
    repeat
        event, _, _, _, message, _ = os.pullEvent()
    until event == "modem_message" or event == "timer"
    os.cancelTimer(timerId)
    if isRunning then
        if type(turtleProgram) == "table" and type(turtleProgram.tick) == "function" then
            isRunning = turtleProgram.tick() and turtle.getFuelLevel() > 0
        else
            isRunning = false
        end
    end
    if event == "modem_message" then
        if type(message[3]) == "nil" or message[3] == os.getComputerID() then
            if message[1] == "download" then
                local f = fs.open("program.lua", "w")
                if f then
                    f.write(message[2])
                    f.close()
                    turtleProgram = require("program")
                else
                    print("Unable to open file program.lua")
                end
            elseif message[1] == "start" then
                isRunning = true
                if type(turtleProgram) == "nil" then
                    turtleProgram = require("program")
                    if turtleProgram and type(turtleProgram.resume) == "function" then
                        turtleProgram.resume("data")
                    end
                end
            elseif message[1] == "stop" then
                isRunning = false
                if turtleProgram and type(turtleProgram.suspend) == "function" then
                    turtleProgram.suspend("data")
                end
            elseif message[1] == "refuel" then
                for slot = 1, 16 do
                    turtle.select(slot)
                    turtle.refuel()
                end
            end
        end
    end
    print("Sending status update..")
    modem.transmit(38,37,{"status", id=os.getComputerID(), isRunning=isRunning, fuel=turtle.getFuelLevel(), time=os.date("%R:%S")})
end