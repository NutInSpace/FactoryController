local defaultMin = 10 --export minimum transfer unit
  
local function sendOrder(id, qty)
   d("waitress:sendOrder :"..id)
   if emitter == nil then
       e("no emitter")
   else
       order = "id:"..id..",qty:"..qty
       d("sendOrder: "..order)
       emitter.send(mode, order)
       return true
   end
   -- todo: confirm 
   return false
end
    
-- Assign new work
local function assignOrders()
    d("waitress:assignOrders")
    if #waitress > 0 then
        local r = waitress[#waitress]
        local tu = waitress_tu[#waitress_tu]
        
        -- Remote Order
        if emitter ~= nil then
            d("waitress:sendOrer")
            if sendOrder(r.id, r.quantity) then
               table.remove(waitress)
            end
        end
        
        -- Local Order
        if #waitress_tu > 0 then
            if configureMachine(tu, r.id, r.quantity) then
                d("waitress:assignedOrder")
                table.remove(waitress)
                table.remove(waitress_tu)
            end
        --else
        --   e("waitress:can't assign")
        end
    -- no orders left
    else
        d("waitress: jobs done!")
        unit.stopTimer("waitress")  -- fixed typo
    end
end

-- Function to add a new item with a minimum quantity
function addItemMin(t, id, quantity, minQuantity)
    minQuantity = minQuantity or defaultMin
    
    for _, item in ipairs(t) do
        if item.id == id then
            item.quantity = math.max(minQuantity, quantity)
            return true
        end
    end

    local newItem = {id = id, quantity = math.max(minQuantity, quantity)}
    t[#t + 1] = newItem
    return true
end

function addItem(t, id, q)
    return addItemMin(t, id, q)
end

-- Check each machine
local function takeOrders()
    d("waitress:takeOrders")
    waitress = {}
    
    if #machines > 0 then    
        for _, machine in ipairs(machines) do
            for _,r in ipairs(machine.getInputs()) do
                addItem(waitress, r.id, r.quantity)
            end
        end
    else
        e("takeOrder: No Machines")
    end     
    d("waitress:tookOrders "..#waitress)
end

-- Check each machine for cleanup
local function takeCleanupOrders()
    d("waitress:takeCleanupOrders")
    
    if #machines > 0 then    
        for _, machine in ipairs(machines) do
            local r = machine.getOutputs()[1]
            addItem(waitress, r.id, r.quantity)
        end
    else
        e("takeOrder: No Machines")
    end     
    d("waitress:tookOrders "..#waitress)
end

-- Check each machine for cleanup
local function takeSideProductOrders()
    d("waitress:takeSideProductOrders")
    
    if #machines > 0 then    
        for _, machine in ipairs(machines) do
            for _,r in ipairs(machine.getOutputs()) do
                addItem(waitress, r.id, r.quantity)
            end
        end
    else
        e("takeOrder: No Machines")
    end     
    d("waitress:tookOrders "..#waitress)
end

-- SETUP:
d("waitress:tick")
-- Find what they want
if waitress == nil then
    takeOrders()
    waitress_tu = transfer_units
elseif #transfer_units > #waitress then
    takeCleanupOrders()
elseif #transfer_units > #waitress then
    takeSideProductOrders()
else
    assignOrders()
end

