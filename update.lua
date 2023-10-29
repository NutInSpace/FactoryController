-- System print update
--system.print("update")
screen = screens[1]

-- Initialize variables
sorted = {}
text = ""
status = " " .. status .. "\n"

-- Process chef items
if #chef_tu < 10 then
    for id,qty in ipairs(chef_tu) do
        text = text .. "G,Transfer: " .. getName(id) .. " << " .. qty .. "\n"
    end
else
    status = status .. "\nW,Transfer: " .. #chef_tu
end

-- Process chef items
if #chef < 10 then
    for _, recipe in ipairs(chef) do
        text = text .. "G,Chef: " .. getName(recipe.id) .. "\n"
    end
else
    status = status .. "\nW,Chef: " .. #chef
end

-- Process databank items
if databanks[1] ~= nil then
    keylist = databanks[1].getKeyList()
    if #keylist < 10 then
        for i, v in ipairs(keylist) do
            text = text ..
                   "DB " ..
                   system.getItem(v).displayName .. 
                   " qty: " .. 
                   databanks[1].getFloatValue(v) .. "\n"
        end
    else
        status = status .. "\nW,Databank[1]: " .. #keylist
    end
end

-- Process machine inputs
if #chef_tu < 10 then
    for id, qty in pairs(chef_tu) do
        text = text .. "W,Input: " .. getName(id) .. " qty: " .. qty .. "\n"
    end
else
    status = status .. "\nW,Input: " .. #chef_tu
end

-- Add status
text = status .. "\n\n" .. text

-- Padding Text so machines are in the next row
local count = select(2, text:gsub('\n', '\n'))
text = text .. string.rep("\n", 21 - count)

-- Process machines
local function processMachine(machine)
    local state = machine.getState()
    local msg = " >> "
    local outputs = machine.getOutputs()
    if outputs and outputs[1] and outputs[1].id then
        msg = msg .. getName(outputs[1].id)
        msg = msg .. " " .. outputs[1].quantity
        msg = msg .. "/" .. machine.getInfo().maintainProductAmount
    end

    if state == 1 then -- Stopped
        text = text .. "R,Stopped: " .. machine.getName() .. msg .. "\n"
    elseif state == 2 then -- Running
        text = text .. "G,Active: " .. machine.getName() .. msg .. "\n"
    elseif state == 3 then -- Missing Input
        text = text .. "Y,Blocked: " .. machine.getName() .. msg .. "\n"
    elseif state == 4 then -- Container Full
        text = text .. "W,Blocked: " .. machine.getName() .. msg .. "\n"
    elseif state == 5 then -- Missing Container
        text = text .. "R,Missing Link: " .. machine.getName() .. msg .. "\n"
    elseif state == 6 then -- Pending
        text = text .. "W,Idle: " .. machine.getName() .. msg .. "\n"
    elseif state == 7 then -- Missing Schematic
        text = text .. "Y,Unlicensed: " .. machine.getName() .. msg .. "\n"
    end
end

-- Process machines
for _, machine in ipairs(machines) do
    processMachine(machine)
end

-- Process transfer units
for _, machine in ipairs(transfer_units) do
    processMachine(machine)
end

-- Compress text
text = string.gsub(text, "Basic" , "")
text = string.gsub(text, "Uncommon" , "")
text = string.gsub(text, "Advanced", "")
text = string.gsub(text, "Rare", "")
text = string.gsub(text, "Exotic", "")
--text = string.gsub(text, "I"  , "Industry")
--text = string.gsub(text, "S"  , "Smelter")
--text = string.gsub(text, "E"  , "Electronics")
--text = string.gsub(text, "R"  , "Refiner")
--text = string.gsub(text, "P"  , "Printer")
--text = string.gsub(text, "M"  , "Metalwork")
text = string.gsub(text, "Honeycomb Refinery m", "HC")
text = string.gsub(text, "Transfer Unit l", "TU")
text = string.gsub(text, "Transfer Unit", "TU")
text = string.gsub(text, "Industry m", "")
text = string.gsub(text, "industry m", "")
text = string.gsub(text, "Industry", "")
text = string.gsub(text, "Product", "")
text = string.gsub(text, "Assembly Line", "AL")
text = string.gsub(text, "  ", " ")

-- Set script input on the screen
screen.setScriptInput(banner .. text)

