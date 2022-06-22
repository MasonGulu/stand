local mineOutArea = {}
mineOutArea.airHorizontalTarget = 5
mineOutArea.airVerticalTarget = 4

mineOutArea.airHorizontalSeen = 0
mineOutArea.airVerticalSeen = 0

mineOutArea.verticalBlocksMoved = 0

mineOutArea.modes = {
    ON_GROUND_TO_MOVE_FORWARD = 0,
    MOVING_AND_MINING_UP = 1,
    MOVING_DOWN = 2
}

mineOutArea.mode = mineOutArea.modes.ON_GROUND_TO_MOVE_FORWARD

function mineOutArea.tick()
    if mineOutArea.airHorizontalSeen < mineOutArea.airHorizontalTarget then
        if mineOutArea.mode == mineOutArea.modes.ON_GROUND_TO_MOVE_FORWARD then
            if turtle.dig("left") then
                mineOutArea.airHorizontalSeen = 0
            else
                mineOutArea.airHorizontalSeen = mineOutArea.airHorizontalSeen + 1
            end
            turtle.forward()
            mineOutArea.mode = mineOutArea.modes.MOVING_AND_MINING_UP
        elseif mineOutArea.mode == mineOutArea.modes.MOVING_AND_MINING_UP then
            if turtle.digUp("left") then
                mineOutArea.airVerticalSeen = 0
            else
                mineOutArea.airVerticalSeen = mineOutArea.airVerticalSeen + 1
            end
            turtle.up()
            mineOutArea.verticalBlocksMoved = mineOutArea.verticalBlocksMoved + 1
            if mineOutArea.airVerticalSeen > mineOutArea.airVerticalTarget then
                mineOutArea.airVerticalSeen = 0
                mineOutArea.mode = mineOutArea.modes.MOVING_DOWN
                turtle.dig("left")
                turtle.forward()
            end
        elseif mineOutArea.mode == mineOutArea.modes.MOVING_DOWN then
            turtle.digDown("left")
            turtle.down()
            mineOutArea.verticalBlocksMoved = mineOutArea.verticalBlocksMoved - 1
            if mineOutArea.verticalBlocksMoved == 0 then
                mineOutArea.mode = mineOutArea.modes.ON_GROUND_TO_MOVE_FORWARD
            end
        end
        return true
    end
    return false
end

local function filterFunctions(table)
    local newTable = {}
    for key, value in pairs(table) do
        if type(value) ~= "function" then
            if type(value) == "table" then
                newTable[key] = filterFunctions(value)
            else
                newTable[key] = value
            end
        end
    end
    return newTable
end

local function mergeTable(table, loadedTable)
    for key, value in pairs(loadedTable) do
        if type(value) == "table" then
            mergeTable(table[key], value)
        else
            table[key] = value
        end
    end
end

function mineOutArea.suspend(filename)
    local f = fs.open(filename, "w")
    if f then
        f.write(textutils.serialise(filterFunctions(mineOutArea)))
    end
end

function mineOutArea.resume(filename)
    local f = fs.open(filename, "r")
    if f then
        mergeTable(mineOutArea, textutils.serialise(f.readAll()))
    end
end

return mineOutArea

