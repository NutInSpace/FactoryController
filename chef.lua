local function findNewTask(m)
    if (#chef > 0) and (#chef_machines > 0) then
        if configureMachine(m, chef[#chef].id, chef[#chef].quantity) then
            table.remove(chef)
            --table.remove(chef_machines)
        end
    else
        d("chef: jobs done!")
        unit.stopTimer("chef")
    end

end

-- Load machine up with work.
if chef_machines == nil then
    chef_machines = machines
end

findNewTask(chef_machines[#chef_machines])
