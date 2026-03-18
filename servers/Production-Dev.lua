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
-- Monitor players, zombies, NPCs

Game.SubscribeTo(Events.OnEverySecond, function()

    local npc_count = NPCs.Count()
    local player_count = Players.Count()
    local zombie_count = Zombies.Count()
    local total_count = npc_count + player_count 
    -- Game.Print(string.format("<CLS>Total survivors: %d (%d players), zombies: %d", 
    --     total_count, 
    --     player_count,
    --     zombie_count))

    local daytime = Game.GetDayTime()
    if daytime > 2 and daytime < 22 then
        -- Game.Print(string.format("Countdown to sunset: %.1f ", 23 - daytime))
    end

    -- Game.Print(daytime)
end)

--=========================================================
-- Respawn zombies

Game.SubscribeTo(Events.OnEverySecond, function()

    local npc_count = NPCs.Count()
    local player_count = Players.Count()
    local zombie_count = Zombies.Count()

    local max_zombies = (player_count + npc_count) * 6

    local spawn_area = {
        x = -4932 + math.random(400),
        y = -16774 + math.random(400),
        z = 2601
    } 
    -- -4932,-16774,2601

    spawn_area.z = Game.GroundAt(
        spawn_area.x,
        spawn_area.y,
        spawn_area.z)

    local aggressive = true
    local sprinter = math.random(100) < 10
    
    if Zombies.Count() > max_zombies then return end

    Zombies.Create(spawn_area.x,
        spawn_area.y,
        spawn_area.z,
        math.random(360),
        aggressive,
        sprinter)

end)

--=========================================================
-- Replenish arrows, bow, axe


local debouncer = Debouncer.new(5)
Game.SubscribeTo(Events.OnEverySecond, function()

    if debouncer:call() then return end

    for pos_player = 1, Players.Count() do 

        local player = Players.At(pos_player)

        Players.SetAttribute(player, "hunger", 100)
        Players.SetAttribute(player, "thirst", 100)
        
        local energy = Players.GetAttribute(player, "energy")
        if energy > 10 then
            energy = energy - 1
            Players.SetAttribute(player, "energy", energy)
        end

        if not Util.InventoryFind(player, "arrow-wood") then
            Inventory.AddTo(player, "arrow-wood", 40)
            Players.FlashMessage(player, "You got 40 arrows")
        end

        if not Util.InventoryFind(player, "bow") then
            Inventory.AddTo(player, "bow")
        end

        if not Util.InventoryFind(player, "axe") then
            Inventory.AddTo(player, "axe")
        end

    end

end)

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

