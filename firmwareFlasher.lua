local fw = {}

function fw.tick()
    print("Waiting for firmware..")
    local event, _, _, _, message, _ = os.pullEvent("modem_message")
    if (message[1] == "download") then
        print("File recieved..")
        local f = fs.open("startup.lua", "w")
        if f then
            f.write(message[2])
            f.close()
            print("Firmware applied.")
            sleep(1)
            os.reboot()
        end
    end
    
end

return fw