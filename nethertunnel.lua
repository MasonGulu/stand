local netherTunnel = {}

netherTunnel.blocksBetweenPattern = 5

netherTunnel.blocksMovedSinceLastPattern = 0

netherTunnel.slot = 16

local STATES = {
    MOVING_FORWARD = 1,
    DO_PATTERN = 2
}


netherTunnel.state = STATES.MOVING_FORWARD

function netherTunnel.tick()
    if netherTunnel.state == STATES.MOVING_FORWARD then
        turtle.forward()
        netherTunnel.blocksMovedSinceLastPattern = netherTunnel.blocksMovedSinceLastPattern + 1
        if netherTunnel.blocksMovedSinceLastPattern > netherTunnel.blocksBetweenPattern then
            netherTunnel.blocksMovedSinceLastPattern = 0
            netherTunnel.state = STATES.DO_PATTERN
        end
    elseif netherTunnel.state == STATES.DO_PATTERN then
        if turtle.getItemCount(netherTunnel.slot) == 0 then
            netherTunnel.slot = netherTunnel.slot - 1
        end
        turtle.select(netherTunnel.slot)
        turtle.turnLeft()
        if turtle.detect() then
            turtle.dig()
            turtle.place()
        end
        turtle.turnRight()
        turtle.turnRight()
        if turtle.detect() then
            turtle.dig()
            turtle.place()
        end
        turtle.turnLeft()
        netherTunnel.state = STATES.MOVING_FORWARD
    end
    
    
    return true
end

return netherTunnel

