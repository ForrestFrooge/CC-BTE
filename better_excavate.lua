local OT = turtle
turtle = setmetatable({},{__index = OT})

local quarry_depth = 111
local sizeX , sizeY = 3,3

local xPos, zPos = 0,0
local xDir , zDir = 0,1
local depth = 0

local lkl_x,lkl_z,lkl_y = 0,0,0
local lkd_x,lkd_z = 0,1

local fuel_threshold = 100

local _turn_direction = false

function turtle.bigDig()
    turtle.digUp()
    turtle.dig()
    turtle.digDown()
end

function turtle.Iforward()
    while turtle.inspect() do
        local _,temp = turtle.inspect()

        if temp.name == "minecraft:water" or temp.name == "minecraft:lava" then
            break
        end

        turtle.dig()

    end
    turtle.forward()
    xPos, zPos = xPos + xDir, zPos + zDir
end

function turtle.turnAround()
    turtle.IturnLeft()
    turtle.IturnLeft()
end

function turtle.goDown()
    for d = 1, 3 do
        turtle.digDown()
        turtle.down()
        depth = depth + 1
    end
end

function turtle.digAround()
    local turn = turtle[_turn_direction and "IturnLeft" or "IturnRight"]
    turn()
    turtle.bigDig()
    turtle.Iforward()
    turn()
end

function turtle.swap_turn_direction()
    _turn_direction = not _turn_direction
end

function turtle.IturnLeft()
	turtle.turnLeft()
	xDir, zDir = -zDir, xDir
end

function turtle.IturnRight()
	turtle.turnRight()
	xDir, zDir = zDir, -xDir
end

function turtle.goTo(x, y, z, xd , zd)

    while depth > y do
        turtle.up()
        depth = depth - 1
    end

    while depth < y do
        turtle.down()
        depth = depth + 1
    end

    if xPos ~= x then
        
        while xDir ~= -1 do
            turtle.IturnLeft()
        end

        while xPos > x do
            turtle.Iforward()
        end

    end

    if zPos ~= z then
        while zDir ~= -1 do
            turtle.IturnLeft()
        end

        while zPos > z do
            turtle.Iforward()
        end

    end

	while zDir ~= zd or xDir ~= xd do
		turtle.IturnLeft()
	end

end

function turtle.deposit_items()
    for i = 1, 16 do
        turtle.select(i)
        turtle.dropDown()
    end
    turtle.select(1)
end

function turtle.deposit_items_at_chest()
    turtle.set_lkd()
    turtle.set_lkl()

    turtle.goTo(0,0,0,0,-1)
    turtle.deposit_items()
    
    if turtle.check_required_fuel() then
        turtle.wait_for_refuel()
    end

    turtle.goTo(0,0,0,0,1)
end

function turtle.set_lkl()
    lkl_x,lkl_y,lkl_z = xPos,depth,zPos
end

function turtle.set_lkd()
    lkd_x, lkd_z = xDir, lkd_z
end

function turtle.wait_for_refuel()
    turtle.select(1)
    
    if turtle.getFuelLevel() < fuel_threshold then
        print("Awaiting for "..fuel_threshold - turtle.getFuelLevel() .." fuel.")
    end

    while turtle.getFuelLevel() < fuel_threshold do
        turtle.refuel()
        os.sleep(5)
    end
    
    print("Current fuel level : ".. turtle.getFuelLevel())
    print("Sufficient fuel :)")

end

function turtle.check_required_fuel()
    local fuel_cost = (xPos + depth + zPos)
    local fuel_left = turtle.getFuelLevel()

    if (fuel_cost - fuel_left) < fuel_threshold then
        return true
    end
    return false

end

function turtle.check_inventory_capacity()
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item == nil then return true
    end
    return false
end


if math.fmod(quarry_depth,3) ~= 0 then
    print("ERROR - DEPTH IS NOT DIVISIBLE BY THREE")
    return
end


turtle.Iforward()

for d = 1, quarry_depth/3 do

    turtle.goDown()

    for x = 1, sizeX do

        for y = 1, sizeY - 1 do

            turtle.bigDig()
            turtle.Iforward()
        end

        if x ~= sizeX then
            turtle.digAround()
            turtle.swap_turn_direction()
        end
    end
    if turtle.check_inventory_capacity() then
        turtle.deposit_items_at_chest()
        turtle.goTo(lkl_x,lkl_y,lkl_z,lkd_x,lkd_z)
    end
    turtle.turnAround()
    turtle.bigDig()

end

turtle.deposit_items_at_chest()
