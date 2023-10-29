local cmd = screens[1].getScriptOutput()

if cmd ~= nil then
    screens[1].clearScriptOutput()
end

if cmd == "stop" then
    chef = {}
    machine_inputs = {}
    cooked = {}
    uncooked = {}
    status = "Stopping Machines!"
    
    for k, m in ipairs(machines) do
        m.stop(false, false)
    end
    
    for k, m in ipairs(transfer_units) do
        m.stop(false, false)
    end
elseif cmd == "run" then
    if #machines > 0 then
        status = "Waiting for chef..."
        unit.setTimer("chef", 5)
    else
        status = "Error: No Machines!"
    end
    
    if #machines > 0 or #transfer_units > 0 then
        unit.setTimer("waitress", (#machines + #transfer_units) * 2)
    end
elseif cmd ~= nil then
    local num = tonumber(cmd)
    
    if num then
        chef = {}
        machine_inputs = {}
        cooked = {}
        uncooked = {}
        status = "Ordering: " .. getName(cmd)
        local control_maintain = 1000 -- export control maintain
        
        for i, machine in ipairs(machines) do
            table.insert(chef, { id = num, quantity = control_maintain * i })
        end
    else
        print("Invalid cmd")
    end
end

