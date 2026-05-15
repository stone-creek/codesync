--=========================================================
-- Utils

Util = {}

--=========================================================
-- Debouncer

Debouncer = {}
Debouncer.__index = Debouncer
function Debouncer.new(interval)
    local self = setmetatable({}, Debouncer)
    self.interval = interval
    self.counter = 0
    return self
end
function Debouncer:call()
    self.counter = self.counter + 1
    if self.counter >= self.interval then
        self.counter = 0
        return false
    end
    return true
end

--=========================================================
-- Util: does player have any inside his inventory?

Util.InventoryFind = function(player, item_class)
    
    for pos = 1, Inventory.Count(player) do
        
        local item = Inventory.At(player, pos)
        local class = Inventory.ClassOf(player, item)

        if class == item_class then
            return true
        end
    end

    return false
end

--=========================================================
-- Util: serialize table to string

Util.ToJson = function(t, indent)
    indent = indent or ""
    local result = "{\n"
    local inner = indent .. "  "
    for k, v in pairs(t) do
        local key = type(k) == "string" and ('["' .. k .. '"]') or ("[" .. k .. "]")
        local val
        if type(v) == "table" then
            val = serializeTable(v, inner)
        elseif type(v) == "string" then
            val = '"' .. v:gsub('"', '\\"') .. '"'
        else
            val = tostring(v)
        end
        result = result .. inner .. key .. " = " .. val .. ",\n"
    end
    return result .. indent .. "}"
end

--=========================================================
-- Util: deserialize table from string

Util.FromJson = function(s)
    local fn, err = load("return " .. s)
    if not fn then return nil, err end
    return fn()
end
