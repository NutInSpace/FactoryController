--Function
--onRecievd(*,*)

d("recieved")
d("message: "..message)
d("channel: "..channel)

-- Function to split the string and extract id and qty
local function extractValues(str)
    d("waitress:extractValues")
    local id, qty
    for key, value in string.gmatch(str, "(%w+):(%w+)") do
        if key == "id" then
            id = value
        elseif key == "qty" then
            qty = value
        end
    end
    return id, qty
end

function receiveOrder(message)
    d("waiterss:recieved: "..message)
    -- Extracting id and qty
    local id, qty = extractValues(message)
    d("id: "..id)
    d("qty: "..qty)
    addItem(waitress, tonumber(id), tonumber(qty))
end

receiveOrder(message)
