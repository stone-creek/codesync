--=========================================================
-- Respawn zombies

local debouncer_zombies = Debouncer.new(NEW_ZOMBIE_MIN_INTERVAL_SECONDS)
Game.SubscribeTo(Events.OnEverySecond, function()

    if debouncer_zombies:call() then return end
    
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
-- Respawn NPCs

local debouncer_npcs = Debouncer.new(NEW_NPC_MIN_INTERVAL_SECONDS)
Game.SubscribeTo(Events.OnEverySecond, function()

    if debouncer_npcs:call() then return end

    local spawn_location = {
        x = -11060 + math.random(1200),
        y = -16080 + math.random(1200),
        z = 2640
    } 

    spawn_location.z = Game.GroundAt(
        spawn_location.x,
        spawn_location.y,
        spawn_location.z)

    if NPCs.Count() > MAX_NPCs then return end

    NPCs.Create(spawn_location.x,
        spawn_location.y,
        spawn_location.z,
        math.random(360))

end)