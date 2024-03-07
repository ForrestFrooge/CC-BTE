local OT = turtle
turtle = setmetatable({},{__index = OT})

turtle.xPos,turtle.yPos,turtle.zPos = 0,0,0
turtle.xDir,turtle.zDir = 0,1



local whitelist = {"minecraft:coal","minecraft:charcoal","minecraft:raw_copper","minecraft:raw_copper_block","minecraft:raw_iron","minecraft:raw_iron_block","minecraft:raw_gold","minecraft:raw_gold_block","minecraft:diamonds","minecraft:redstone"}

local fuel_threshold = 500

local function bool_to_number(value)
    return value and 1 or 0
end

function turtle.turnLeft()
    OT.turnLeft()
    turtle.xDir,turtle.zDir = -turtle.zDir,turtle.xDir
end

function turtle.turnRight()
    OT.turnRight()
    turtle.zDir,turtle.xDir = -turtle.xDir,turtle.zDir
end

function turtle.turnAround()
    turtle.turnLeft()
    turtle.turnLeft()
end

function turtle.forward()
    while turtle.is_block_front() do
        turtle.dig()
    end
    OT.forward()
    turtle.xPos , turtle.zPos = turtle.xPos + turtle.xDir , turtle.zPos + turtle.zDir
end

function turtle.back()
    OT.back()
    turtle.xPos , turtle.zPos = turtle.xPos - turtle.xDir , turtle.zPos - turtle.zDir
end

function turtle.up()
    while turtle.is_block_above() do
        turtle.digUp()
    end
    OT.up()
    turtle.yPos = turtle.yPos + 1
end

function turtle.down()
    while turtle.is_block_below() do
        turtle.digDown()
    end
    OT.down()
    turtle.yPos = turtle.yPos - 1
end

function turtle.bigDig()
    turtle.digUp()
    turtle.dig()
    turtle.digDown()
end

function turtle.digMoveDown(x)
    for i = 1, x do
        turtle.digDown()
        turtle.down()
    end
end

function turtle.is_block_above()
    local _, block_data = turtle.inspectUp()
    if block_data.name == nil then return false end
    if block_data.name == "minecraft:water" then return false end
    if block_data.name == "minecraft:lava" then return false end
    return true
end

function turtle.is_block_below()
    local _, block_data = turtle.inspectDown()
    if block_data.name == nil then return false end
    if block_data.name == "minecraft:water" then return false end
    if block_data.name == "minecraft:lava" then return false end
    return true
end

function turtle.is_block_front()
    local _, block_data = turtle.inspect()
    if block_data.name == nil then return false end
    if block_data.name == "minecraft:water" then return false end
    if block_data.name == "minecraft:lava" then return false end
    return true
end

function turtle.digAround(x)
    turtle[x % 2 == 0 and "turnLeft" or "turnRight"]()
    turtle.bigDig()
    turtle.forward()
    turtle[x % 2 == 0 and "turnLeft" or "turnRight"]()
end

function turtle.goTo(x, y, z)
    
    -- Y AXIS
    
    while turtle.yPos ~= y do
        turtle[turtle.yPos < y and "up" or "down"]()
    end

    -- Z AXIS

    local dir = turtle.zPos - z

    if turtle.zPos ~= z then
        

        if dir < 0 then dir = 1 elseif dir > 0 then dir = -1 end
        
        
        while turtle.zDir ~= dir do
            turtle.turnLeft()
        end

        while turtle.zPos ~= z do
            turtle.forward()
        end

    end

    -- X AXIS

    if turtle.xPos ~= x then

        dir = turtle.xPos - x

        if dir < 0 then dir = 1 elseif dir > 0 then dir = -1 end
        
        while turtle.xDir ~= dir do
            turtle.turnLeft()
        end

        while turtle.xPos ~= x do
            turtle.forward()
        end

    end


end

function turtle.setDir(xd,zd)    
    while turtle.xDir ~= xd do
        turtle.turnLeft()
    end

    while turtle.zDir ~= zd do
        turtle.turnLeft()
    end

end

function turtle.refuel()
    for i = 1, 16 do
        turtle.select(i)
        OT.refuel()
    end
    turtle.select(1)
end

function turtle.deposit()
    for i = 1, 16 do
        turtle.select(i)
        turtle.drop()
    end
    turtle.select(1)
end

function turtle.getCoords()
    return turtle.xPos,turtle.yPos,turtle.zPos
end

function turtle.getDir()
    return turtle.xDir,turtle.zDir
end

function turtle.hasCapacity()
    for i = 1 ,16 do
        local item = turtle.getItemDetail(i)
        if item == nil then return true end
    end
    return false
end

function turtle.awaitRefuel()
    print("Current fuel capacity : "..turtle.getFuelCapacity())
    print("Required fuel capacity : "..fuel_threshold)
    while turtle.getFuelCapacity() < fuel_threshold do
        turtle.refuel()
        os.sleep(5)
    end
end

function turtle.checkFuel()
    if turtle.getFuelLevel() < fuel_threshold then
        turtle.refuel()
    end
    if turtle.getFuelLevel() < fuel_threshold then
        turtle.goTo(0,0,0)
        turtle.setDir(0,1)
        turtle.awaitRefuel()
    end
end

function turtle.checkCapacity()
    if turtle.hasCapacity() == false then

        local r_xDir , r_zDir = turtle.getDir()
        local r_xPos,r_yPos,r_zPos = turtle.getCoords()


        turtle.goTo(0,0,0)
        turtle.setDir(0,-1)
        turtle.deposit()
        turtle.setDir(0,1)

        turtle.checkFuel()

        turtle.goTo(r_xPos,r_yPos,r_zPos)

        turtle.setDir(r_xDir , r_zDir)
    end
end


function turtle.excavate(xSize , zSize , depth)
    
    local turn_direction = true

    for d = 1, depth / 3 do

        turtle.digMoveDown(3)

        for x = 1 , xSize do

            for z = 1, zSize - 1 do
                turtle.bigDig()
                turtle.forward()
            end
            
            if x ~= xSize then
                turtle.digAround(bool_to_number(turn_direction))
                turn_direction = not turn_direction
            end

            turtle.checkCapacity()
        end

        turtle.turnAround()
        turtle.bigDig()
        
    end

end

return turtle
