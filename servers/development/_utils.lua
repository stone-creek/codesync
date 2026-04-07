-- Utils

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

Util = {}
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

