for k, light in ipairs(lights) do
    light.activate()
end

local function setColor(red, green, blue)
    for k, light in ipairs(lights) do
        light.setColor(red, green, blue)
    end
end

local function setColorRand(red, green, blue)
    lights[math.random(#lights)].setColor(red, green, blue)
end

red = 2
green = 0
blue = 0

-- Switch to transfer units
if machines[1] == nil and transfer_units[1] ~= nil then
    light_machines = transfer_units
else
    light_machines = machines
end
-- Global Init whoopies
if light_tick == nil then
    light_tick = 1
end

if light_machines[light_tick] ~= nil then
    state = light_machines[light_tick].getState()
    red = 0
    green = 0
    blue = 0
    
    
    if state == 1 then -- Stopped
        red = 2
    elseif state == 2 then -- Running
        green = 3
    elseif state == 3 then -- Missing Input
        red = 1.5
        green = 1.5
        --alert("missing input")
    elseif state == 4 then -- Container Full
        red = 3
        e("container full")
    elseif state == 5 then -- Missig Container
        red = 5
        e("missing container")
    elseif state == 6 then -- Pending
        green = 2
    elseif state == 7 then -- Missing Schematic
        red = 2
        green = 2
        e("missing schematic")
    end
end

setColor(red, green, blue)

--tick
light_tick = light_tick + 1
if light_tick > #light_machines then
    light_tick = 1
end

