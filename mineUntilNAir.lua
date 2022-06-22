local mineUntilNAir = {}
mineUntilNAir.airTarget = 10

mineUntilNAir.airSeen = 0

function mineUntilNAir.tick()
    if mineUntilNAir.airSeen < mineUntilNAir.airTarget then
        if turtle.dig("left") then
            mineUntilNAir.airSeen = 0
        else
            mineUntilNAir.airSeen = mineUntilNAir.airSeen + 1
        end
        turtle.forward()
        return true
    end
    return false
end

return mineUntilNAir

