banner = "DU-FACTORY CONTROL 10.29.23.02"
status = "onStart()"
unit.hideWidget()

system.print(status)

-- Helper Functions
function appendTables(...)
    local res = {}
    for _, tbl in ipairs{...} do
        for _, value in ipairs(tbl) do
            table.insert(res, value)
        end
    end
    return res
end

-- GLOBALS
chef = {}           -- Recipes[index]: {item.id, item.qty}
chef_tu = {}        -- Recipes[index]: {item.id, item.qty}

-- links to program boards
core = nil
receiver = nil
emitter = nil

screens = {}
containers = {}
mining_units = {}
machines = {}
transfer_units = {}
lights = {}
databanks = {}
unknown = {}
br = {}

name = DUPlayer.getName()

status = "onStart() : slot init"
-- Debug
function d(msg)
    status = msg
    system.print(status)
end
-- Error Message
function e(msg)
    error_msg = msg
    system.print("ERR:"..msg)
end
        
for slot_name, slot in pairs(unit) do
    if type(slot) == "table"
        and type(slot.export) == "table"
        and slot.getClass
    then
        slot.slotname = slot_name
        if slot.getClass():lower() == 'screenunit' then
            table.insert(screens,slot)
        elseif slot.getClass():lower() == "containersmallgroup" then
            table.insert(containers,slot)
        elseif slot.getClass():lower() == "containermediumgroup" then
            table.insert(containers,slot)
        elseif slot.getClass():lower() == "containerlargegroup" then
            table.insert(containers,slot)
        elseif slot.getClass():lower() == "containerxlgroup" then
            table.insert(containers,slot)
        elseif slot.getClass():lower() == "containerxxlgroup" then
            table.insert(containers,slot)
        elseif slot.getClass():lower() == "containerxxxlgroup" then
            table.insert(containers,slot)
        elseif slot.getClass():lower() == "itemcontainer" then
            table.insert(containers,slot)
        elseif slot.getClass():lower() == 'miningunit' then
            table.insert(mining_units,slot)
        elseif slot.getClass():lower() == 'lightunit' then
            table.insert(lights,slot)
        elseif slot.getClass():lower() == 'industry1' then
            table.insert(machines,slot)
            tier1 = true
        elseif slot.getClass():lower() == 'industry2' then
            table.insert(machines,slot)
            tier2 = true
        elseif slot.getClass():lower() == 'industry3' then
            table.insert(machines,slot)
            tier3 = true
        elseif slot.getClass():lower() == 'industry4' then
            table.insert(machines,slot)
            tier4 = true
        elseif slot.getClass():lower() == 'industryunit' then
            table.insert(transfer_units,slot)
        elseif slot.getClass():lower() == 'coreunitstatic' then
            core = slot
        elseif slot.getClass():lower() == 'coreunitdynamic' then
            core = slot
        elseif slot.getClass():lower() == 'coreunitspace' then
            core = slot
        elseif slot.getClass():lower() == 'databankunit' then
            table.insert(databanks,slot)
        elseif slot.getClass():lower() == 'receiverunit' then
            receiver = slot
        elseif slot.getClass():lower() == "emitterunit" then
            emitter = slot
        elseif  slot.getClass():lower() ~= 'generic' then
            e("")
            e("Unknown Slot       : "..slot.slotname)
            e("Unknown Item Class : "..slot.getClass():lower())
            e("Unknown Item ID    : "..slot.getItemId())
            e("")
            table.insert(unknown, slot)
            unit.exit()
        end
    end
end

-- Credit to Squizz Caphinator for getName
-- Prints the element (less verbose)
names = {}
function getName(id)
    --system.print("getName: "..dump(id))
    if id == nil then return "nil Id" end
    if names[id] == nil then
        name = system.getItem(id).locDisplayNameWithSize
        --system.print("debug-name:"..name)
        name = name:gsub(" xs$", " XS")
        name = name:gsub(" s$", " S")
        name = name:gsub(" m$", " M")
        name = name:gsub(" l$", " L")
        name = name:gsub(" xl$", " XL")
        name = name:gsub(" product$", " Product")
        name = string.gsub(name, "Basic" , "T1")
        name = string.gsub(name, "Uncommon" , "T2")
        name = string.gsub(name, "Advanced", "T3")
        name = string.gsub(name, "Rare", "T4")
        name = string.gsub(name, "Exotic", "T5")
        name = string.gsub(name, "Pure", "")
        name = string.gsub(name, "Product", "")

        names[id] = name
    end
    return names[id] -- .. " (" .. id .. ")"
end

-- Credit to stackoverflow
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-- savedb: saves recipe to the databank
-- args: recipe (float), qty (float)
function savedb(recipe, qty)
    if recipe == nil then
        e("savedb: recipe is invalid!")
    end
    if qty == nil then
        e("savedb: qty is invalid!")
    end
    for _,db in ipairs(databanks) do
        if db.hasKey(recipe) then
            current = db.getFloatValue(recipe)
            if current > qty then
                qty = current
            end
        end
        db.setFloatValue(recipe, qty)
    end
end

-- ku: print format for k
function ku(f)
    units = 1000 --export
    --return string.format("%.2f %%", f/max_rate)
    return f/units.."k " 
end
    
-- ffs: print format 
function ffs(f)      
    -- 100,690.12 %
    local i, j, minus, int, fraction = tostring(f):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    --return minus .. int:reverse():gsub("^,","") .. fraction
    return minus .. int:reverse():gsub("^,","") 
end

-- ffr: print format L/Hr
function ffr(f)
    -- 69.12 L/Hr
    return string.format("%.2f L/Hr", f)
end

-- ffp: print format percentage
function ffp(f)
    -- 69.12 %
    return string.format("%.2f %%", f*100)
end

-- tm: print format time
function tm(value)
    -- Hours : Minutes : Seconds
    hours = value / 3600
    hours = math.floor(hours)
    value = value - hours * 3600
    minutes = value / 60
    minutes = math.floor(minutes)
    value = value - minutes * 60
    
    -- to Float
    --value = value * 1.01
    --value = value / 1.01
    
    return string.format("%02d:%02d:%02d", hours, minutes, value)
end

-- CHEF:
-- Duplicate (requires link to core)
-- Purpose: Find every item on a core, create a recipe list for each unique item on the core.
-- Args: Filter (Boolean) If only one exists then duplicate. This avoids duplicating the factory elements. Default True
-- Args: Maintain (integer) How many to make. If 0, then use element count on core.
function build_recipe_table(filter, maintain)
  local recipes = {}
  
  if core == nil then
    e("Missing link to core!")
  else
    e("Duplicating Items on Core:")
  end

  -- Find everything on the core
  local core_items = {}
  for _, element in pairs(core.getElementIdList()) do
    item = core.getElementItemIdById(element)

    -- track how many we want to transfer
    core_items[item] = (core_items[item] or 0) + 1
  end

  -- Build Recipe List
  for item, qty in pairs(core_items) do

    if filter then
      if qty == 1 then
          table.insert(recipes, { id = item, quantity = maintain })
          d(getName(item) .. " -> " .. qty)
      else
          d("Filtered: " .. getName(item) .. " -> " .. qty)
      end
    else
      if maintain ~= 0 then
          qty = maintain
      end
      table.insert(recipes, { id = item, quantity = qty })
      d(getName(item) .. " -> " .. qty)
    end
  end

  return recipes
end

-- CHEF:
-- Duplicate (requires link to core)
-- Purpose: Find every item on a core, create a recipe list for each unique item on the core.
-- Args: Filter (Boolean) If only one exists then duplicate. This avoids duplicating the factory elements. Default True
-- Args: Maintain (integer) How many to make. If 0, then use element count on core.
function read_container()
  local recipes = {}
  
  if #containers < 1 then
    e("Missing link to container!")
  else
    local wait = containers[1].updateContent()
    if wait > 1 then
        e("Container timeout: "..wait)
    else
        d("Found Items in container:")
    end
  end

  d(dump(containers[1].getContent()))
  --
  --
  -- Build a recipes table -- take everything?
  for id, qty in containers[1].getContent() do
      table.insert(recipes, {id=id, quantity=quantity})
  end
  d("read recipes:"..#recipes)
  return recipes
end

-- CHEF:
-- Purpose: Loads recipes from databank
-- Args: Maintain (integer) How many to make. If 0, then use prescribed qty
function load_recipe_table(maintain)
  local recipes = {}
  for _,db in ipairs(databanks) do
      local keylist = db.getKeyList()
      for _,key in ipairs(keylist) do
            if maintain == nil or maintain == 0 then
                table.insert(recipes, {id=key, quantity=db.getFloatValue(key)})
            else
                table.insert(recipes, {id=key, quantity=maintain})
            end
      end
  end
  d("loaded recipes:"..#recipes)
  return recipes
end

-- For checking that a machine (m) is set to the correct recipe (r) and
-- the correct quantity (q)
function checkMachineConfiguration(m, r, q)
    --d("checkMachineConfiugriation")
    if m == nil then
        e("Machine is nil")
        return false
    end

    local info = m.getInfo()
    if info == nil then
        e("Machine state is nil")
        return false
    end

    if info.currentProducts[1] == nil then
        e("Machine does not have recipe set")
        return false
    end
    
    if info.currentProducts[1].quantity < 1 then
        e("Machine is glitched")
        return false
    end

    if info.state == 1 then
        e("Machine is stopped")
        return false
    end
    
    if info.stopRequested == true then
        e("Machine stop requested")
        return false
    end

    if info.maintainProductAmount == 0 then
        e("Machine is not set to maintain")
        return false
    end

    if info.maintainProductAmount ~= q then
        e("Machine is not set to correct maintain")
        return false
    end

    if info.currentProducts[1].id == nil then
        e("Machine recipe is not set")
        return false
    end

    if info.currentProducts[1].id ~= tonumber(r) then
        e("Machine is misconfigured (wrong recipe)")
        return false
    end

    d("Machine is configured to spec!")
    return true
end

function configureMachine(m, r, q)
    --d("configureMachine")
    if checkMachineConfiguration(m,r,q) == false then
        m.setOutput(tonumber(r))
        m.startRun()
        m.stop(false, false)
        m.startMaintain(tonumber(q))
    end
    
    return checkMachineConfiguration(m, r, q)
end

function configureTransfer(tu, r, q)
    d("configureTransfer")
    --tu.stop(false, false)
    --tu.setOutput(tonumber(r))
    --tu.startMaintain(tonumber(q))
    configureMachine(tu, r, q)
    
    return checkMachineConfiguration(tu, r, q)
end

function main_timer_chef()
    local ct = #machines * 0.25
    unit.setTimer("chef", ct)
end

function main_timers_start()
    d("starting: waitress, lights, fade, update, control, timeout")
    
    local ct = #machines * 0.25 
    local wt = (#machines + #transfer_units + 1) * 0.5
    unit.setTimer("waitress", wt)

    if #lights > 0 then
       local lt = (#machines + #transfer_units + 0.4) * 2
       --d("Lights System Active!")
       unit.setTimer("lights", lt)
       unit.setTimer("lights_fade", 0.25)
    end
    if #screens > 0 then
        local st = (#machines + #transfer_units + 0.4) * 0.4
        --d("Screen System Active!")
        unit.setTimer("update", st)
        unit.setTimer("control", 1)
    end
    unit.setTimer("timeout", 60 + ((ct+wt)*(#machines+#transfer_units)))
end

d("onStart() : main")

-- MAIN:
-- set the program mode
mode = unit.getName():lower()

-- Industry Modes:
--if mode == "chef" then
--    chef = build_recipe_table(true, 1000)
--    --d("Chef Mode Active!")

--elseif mode == "linecook" then
--    chef = load_recipe_table(0)
--    --d("Linecook Active!")

--elseif mode == "transfer" then
--    temp = load_recipe_table(0)
--    for i,item in ipairs(temp) do
--        machine_inputs[item.id] = item.quantity
--    end
    --d("Transfer Unit Recipes Loaded!")

--elseif mode == "empty" then
    --d("Empty Mode Active!")
    --d("Moving all items in container[1]")
--    machine_inputs = read_container(0)
--    main_timers_start()

--elseif mode == "buffer" then
    --d("Buffer Mode Active!")
    --d("Buffering all items in container[1], maintain=1000")
--    machine_inputs = read_container(1000)
--    main_timers_start()
    
--elseif mode == "maintain" then
    --d("Maintain Mode Active!")
    --d("Building all items in container[1], maintain=1000")
--    chef = read_container(1000)

--    main_timer_chef()
--    main_timers_start()
    
if mode == "duplicate" then
    --d("Duplicate Mode Active!")
    chef = build_recipe_table(false, 0)
    
    main_timer_chef()
    main_timers_start()
    
elseif mode == "container" then
    local container_max_volume = 192000 --export 
    if containers[1] then 
        local max_v = containers[1].getMaxVolume()
        if max_v > 1 then
            container_max_volume = max_v
        end
        local cur_v = containers[1].getItemsVolume()
        local full = (cur_v / max_v) * 3
        for i,light in ipairs(lights) do
            light.activate()
            light.setColor(0,full,0)
        end
    end
    unit.exit()
    
elseif string.find(mode, "assembly") then
    main_timers_start()

-------------------------------------------------------------------------------------------------
----  Do not add anything below this.... 
--------------------------------------------------------------------------------------------------
elseif getName(mode) ~= "" and #machines > 0 then
    local auto_maintain = 50 --export
    local auto_stagger = 50 --export
    d("Loading Recipe: "..getName(mode))
    -- Use the mode for a recipe
    if #chef < 1 then
        for i,m in ipairs(machines) do
            table.insert(chef, { id = mode, quantity = (auto_maintain + i * auto_stagger) })
        end
    end
    
    main_timer_chef()

    main_timers_start()


d("onStart() : building screen script")
    
--------------------------------------------------------------------------------------------------
--- HEY, I SAID DON"T COME DOWN HERE
--------------------------------------------------------------------------------------------------

script = ""
--script = "logMessage(\"Screen: "..banner.."\")"
script = script..[[

-- Background
local background_image = loadImage("assets.prod.novaquark.com/53264/e365787b-8b12-4744-a156-ce11be60969f.png")
--assets.prod.novaquark.com/61625/916a89d6-4103-4b28-9a48-04575d9a2b2b.png


l1 = createLayer()
rx, ry = getResolution()
addImage(l1, background_image, 0, 0, rx, ry)
-- Background


function ToColor(w,x,y,z) return {r = w, g = x, b = y, o = z} end
local white = ToColor(1, 1, 1, 1)
local gray = ToColor(0.3, 0.3, 0.3, 1)
local red = ToColor(1, 0, 0, 1)
local green = ToColor(0, 1, 0, 1)
local yellow = ToColor(0.5, 0.5, 0, 1)
local medium = loadFont('Play', 35)
local small = loadFont('Play', 20)

--# Button class definition called only at the first frame
if not Button then

    -- getEllipsis( font, text, maxWidth)
    -- Return a shorten text string by with with ... at the end
    function getEllipsis(font, text, maxWidth)
        local width = getTextBounds(font, '...')

        for i = 1, #text do
            local line = getTextBounds(font, text:sub(1,i)) + width
            if line > maxWidth then
                return text:sub(1,i-1)..'...'
            end
        end
        return text
    end


    Button = {}
    Button.__index = Button
    -- Button object constructor
    -- .x : X component of the position
    -- .y : Y component of the position
    -- .width : Width of the button
    -- .height : Height of the button
    -- .caption : Associated text caption
    -- .onClick : Function called when the button is clicked
    function Button:new(x, y, width, height, caption, color)
        local self = {
            x = x or 0,
            y = y or 0,
            w = width or 100,
            h = height or 20,
            caption = caption or "",
            onClick = nil
        }

        -- Draws the button on the screen using the given layer
        function self:draw(layer, font)
            -- Localize object data
            local x, y, w, h = self.x, self.y, self.w, self.h
            local min, max = self.min, self.max

            -- Get cursor data
            local mx, my = getCursor()
            local down = getCursorDown()
            local released = getCursorReleased()

            local clicked = false
            -- Determine if the cursor is on the button and switch the state
            if (mx >= x and mx <= x+w) and (my >= y and my <= y+h) then
                
                if down then
                    clicked = true
                    
                -- Call the onClick function when the mouse button is released
                elseif released then
                    if self.onClick then
                        -- Provide cursor position in arguments
                        self:onClick( mx, my)
                    end
                end
                
            end

            --# Draw the button
            -- Define box default strokes style
            setDefaultStrokeColor(layer, Shape_BoxRounded, 1, 1, 1, 1)
            setDefaultStrokeWidth(layer, Shape_BoxRounded, 0.1)

            -- If the button is clicked change the background
            if clicked then 
                setNextFillColor(layer, 0.1, 0.1, 0.1, 1)
            else
                setNextFillColor(layer, color.r, color.g, color.b, 1)
            end
            addBoxRounded(layer, x, y, w, h, 1)

            -- Draw caption and value display          
            local caption = getEllipsis(font, self.caption, w-12)
            local font = font or nil

            setNextTextAlign( layer, AlignH_Center, AlignV_Middle)
            addText( layer, font, caption, x+0.5*w, y+0.5*h)
        end

        return setmetatable(self, Button)
    end

end

function strSplit(a,b)result={} for c in(a..b):gmatch("(.-)"..b) do table.insert(result,c) end; return result end

-- Credit to stackoverflow
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function pad(text, pad)
    if pad == nil then return text end
    if pad < 0 then
        pad = math.abs(pad)
        while string.len(text) < pad do text = " " .. text end
    elseif pad > 0 then
        while string.len(text) < pad do text = text .. " " end
    end
    return text
end



names = {}
function fixText(text)
    if names[text] == nil then
        text = text:gsub("%B ", "Basic ")
        text = text:gsub(" I ", " Industry ")
        text = text:gsub(" S ", " Smelter ")
        text = text:gsub(" E ", " Electronics ")
        text = text:gsub(" 3 ", " 3d ")
        text = text:gsub(" R ", " Refiner ")
        text = text:gsub(" P ", " Printer ")
        text = text:gsub(" M ", " Metalwork ")
        text = text:gsub("TU " , "Transfer Unit ")
        text = text:gsub(" AL ", " Assembly Line ")

        text = text:gsub("`I", "Cycling")
        text = text:gsub("`R", "Running")
        text = text:gsub("`W", "Cycling")
        text = text:gsub("`J", "JAMMED!")
        text = text:gsub("`P", "Cycling")
        text = text:gsub("!!", "!SCHEMATICS!")

        names[text] = text
    end
    return names[text]
end

if not init then
    rx, ry = getResolution()
    init = true

     -- Draw the 3 buttons
    buttonRed = Button:new(rx - .15*rx, 0.65*ry - 16, 150, 42, "Stop", red)
    buttonGreen = Button:new(rx - .15*rx, 0.85*ry - 16, 150, 42, "Run", green)
    buttonBlue = Button:new(rx - .15*rx, 0.75*ry - 16, 150, 42, "Clear", yellow)
    buttonRed.onClick = function(self) logMessage("stop") setOutput('stop') end
    buttonGreen.onClick = function(self) logMessage("run") setOutput('run') end
    buttonBlue.onClick = function(self) logMessage("refresh") setOutput('refresh') end

    recipes = {}
]]
if br then
    local columnSize = 1
    if #br > 5 then
        columnSize = 2
    end
    for i, r in ipairs(br) do
        x = (i-1) % columnSize * 200 - 100
        y = 0.85 - math.floor((i-1) / columnSize) * 0.10
        l1 = "\n    b = Button:new(rx - .50*rx + "..x..", "..y.."*ry - 16, 180, 42,\""..getName(r).."\", gray)"
        l2 = "\n    b.onClick = function(self) logMessage("..r..") setOutput("..r..") end"
        l3 = "\n    table.insert(recipes, b)"
        script = script..l1..l2..l3
    end
end
script = script..[[

end
local fontSize = 14
local font = loadFont('RobotoMono', fontSize)
--local rslib = require('rslib')
local config = { fontSize = fontSize}
local l = createLayer()

xcoords = {}
xcoords[1] = 5
xcoords[2] = 70
xcoords[3] = 255
xcoords[4] = 375
xcoords[5] = 445
xcoords[6] = 525

padding = {}
padding[1] = -5
padding[4] = -5
padding[5] = -5
-- padding[6] = -5

for i,text in pairs(strSplit(getInput(), "\n")) do
    local color = ToColor(0.5, 0.5, 0.5, 0.5)
    -- 2 rows, 50 items
    if i > 20 then
        x = 520
        y = (i-19) * (fontSize + 4)
    else
        x = 10
        y = i * (fontSize + 4)
    end
    split = strSplit(text, ",")
    if split[1] ~= nil then
        local mode = split[1]
        if split[2] then
            text = dump(split[2])
        end
        --text = split[0]
        if mode == "G" or mode == "Cooked" then 
            color = green
        elseif mode == "R" or mode == "Blacklist" then
            color = red
        elseif mode == "Y" then
            color = yellow
        else
            color = white
        end
    end
    if i == 1 then
        color = white
    end
    setNextFillColor(l, color.r, color.g, color.b, color.o)
    addText(l, font, text, x, y, ToColor(0.5, 0.5, 0.5, 0.5))
end

-- Draw buttons
buttonRed:draw(l, medium)
buttonGreen:draw(l, medium)
buttonBlue:draw(l, medium)

for _,r in ipairs(recipes) do
 r:draw(l, small)
end

-- Request a run at each frame
requestAnimationFrame(1)

]]
-- script = script.."logMessage(\"Screen: " .. banner .. "\")"

if #screens > 0 then
    for i,screen in ipairs(screens) do
        screen.setRenderScript(script)
    end
end

d("onStart() : complete")

end
-- END OF MODEs
