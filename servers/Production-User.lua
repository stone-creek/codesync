ZOMBIES_MULTIPLIER = 2
MAX_NPCs = 40
SPRINTER_PERCENT_CHANCE = 20
NEW_NPC_MIN_INTERVAL_SECONDS = 5

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

    -- Game.Print("[CLS totals]")
    -- Game.Print("[CLS clock]")
    -- Game.Print(string.format("[totals]Players:%d NPCs:%d zombies: %d", 
    --     player_count,
    --     npc_count,
    --     zombie_count))

    -- local daytime = Game.GetDayTime()
    -- if daytime > 2 and daytime < 22 then
    --     Game.Print(string.format("[clock]Countdown to sunset: %.1f ", 23 - daytime))
    -- end

end)


--=========================================================
-- Respawn zombies

Game.SubscribeTo(Events.OnEverySecond, function()

    local npc_count = NPCs.Count()
    local player_count = Players.Count()
    local zombie_count = Zombies.Count()

    local max_zombies = (player_count + npc_count) * ZOMBIES_MULTIPLIER

    local spawn_location = {
        x = -4930 + math.random(400),
        y = -16770 + math.random(400),
        z = 2601
    } 

    spawn_location.z = Game.GroundAt(
        spawn_location.x,
        spawn_location.y,
        spawn_location.z)

    local aggressive = true
    local sprinter = math.random(100) < SPRINTER_PERCENT_CHANCE 
    
    if zombie_count >= max_zombies then return end


    Zombies.Create(spawn_location.x,
        spawn_location.y,
        spawn_location.z,
        math.random(360),
        aggressive,
        sprinter)

end)

--=========================================================
-- Replenish arrows, bow, axe

local debouncer_replenish = Debouncer.new(5)
Game.SubscribeTo(Events.OnEverySecond, function()

    if debouncer_replenish:call() then return end

    for pos_player = 1, Players.Count() do 

        local player = Players.At(pos_player)

        Players.SetAttribute(player, "hunger", 100)
        Players.SetAttribute(player, "thirst", 100)
        
        local energy = Players.GetAttribute(player, "energy")
        if energy > 10 then
            energy = energy - 1
            Players.SetAttribute(player, "energy", energy)
        end

        -- Game.Print("[CLS energy]")
        -- Game.Print(
        --     string.format("[energy] Player %s energy: %.0f",
        --         Players.GetName(player),
        --         energy))

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


--=========================================================
-- Respawn NPCs

local debouncer_npcs = Debouncer.new(NEW_NPC_MIN_INTERVAL_SECONDS)
Game.SubscribeTo(Events.OnEverySecond, function()

    if debouncer_npcs:call() then return end

    local spawn_location = {
        x = -9250 + math.random(1200),
        y = -15300 + math.random(1200),
        z = 2641
    } 

    spawn_location.z = Game.GroundAt(
        spawn_location.x,
        spawn_location.y,
        spawn_location.z)

    if NPCs.Count() > MAX_NPCs then return end
    if math.abs(spawn_location.z - 2641) > 200 then return end

    NPCs.Create(spawn_location.x,
        spawn_location.y,
        spawn_location.z,
        math.random(360))

end)
-------
