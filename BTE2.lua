local OT = turtle
turtle = setmetatable({},{__index = OT})


local xPos,yPos,zPos = 0,0,0
local xDir,zDir = 0,1




function turtle.turnLeft()
    OT.turnLeft()
    xDir,zDir = -zDir,xDir
end

function turtle.turnRight()
    OT.turnRight()
    zDir,xDir = -xDir,zDir
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
    xPos , zPos = xPos + xDir , zPos + zDir
end

function turtle.back()
    OT.back()
    xPos , zPos = xPos - xDir , zPos - zDir
end

function turtle.up()
    while turtle.is_block_above() do
        turtle.digUp()
    end
    OT.up()
    yPos = yPos + 1
end

function turtle.down()
    while turtle.is_block_below() do
        turtle.digDown()
    end
    OT.down()
    yPos = yPos - 1
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
    
    while yPos ~= y do
        turtle[yPos < y and "up" or "down"]()
    end

    -- Z AXIS

    local dir = zPos - z

    if dir < 0 then dir = 1 elseif dir > 0 then dir = -1 end
    
    while zDir ~= dir do
        turtle.turnLeft()
    end

    while zPos ~= z do
        turtle.forward()
    end

    -- X AXIS

    dir = xPos - x

    if dir < 0 then dir = 1 elseif dir > 0 then dir = -1 end
    
    while xDir ~= dir do
        turtle.turnLeft()
    end

    while xPos ~= x do
        turtle.forward()
    end



end

function turtle.setDir(xd,zd)    
    print(xDir .. " " .. xd)
    print(zDir .. " " .. zd)
    
    while xDir ~= xd do
        turtle.turnLeft()
    end

    while zDir ~= zd do
        turtle.turnLeft()
    end

end

function turtle.deposit()
    for i = 1, 16 do
        turtle.select(i)
        turtle.drop()
    end
    turtle.select(1)
end

function turtle.getCoords()
    return xPos,yPos,zPos
end

function turtle.getDir()
    return xDir,zDir
end

function turtle.hasCapacity()
    for i = 1 ,16 do
        local item = turtle.getItemDetail(i)
        if item == nil then return true end
    end
    return false
end


function turtle.excavate(xSize , zSize , depth)
    for d = 1, depth / 3 do

        turtle.digMoveDown(3)

        for x = 1 , xSize do

            for z = 1, zSize - 1 do
                turtle.bigDig()
                turtle.forward()
            end
            
            if x ~= xSize then
                turtle.digAround(x)
            end

        end

        turtle.turnAround()
        turtle.bigDig()

        if turtle.hasCapacity() == false then

            local r_xDir , r_zDir = turtle.getDir()
            local r_xPos,r_yPos,r_zPos = turtle.getCoords()

            turtle.goTo(0,0,0)
            turtle.setDir(0,-1)
            turtle.deposit()
            turtle.setDir(0,1)

            turtle.goTo(r_xPos,r_yPos,r_zPos)

            turtle.setDir(r_xDir , r_zDir)

        end
    end

end

turtle.hasCapacity()


turtle.excavate(3,3,90)
turtle.goTo(0,0,0)

turtle.setDir(0,-1)
turtle.deposit()
turtle.setDir(0,1)
