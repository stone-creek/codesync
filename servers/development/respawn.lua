--=========================================================
-- Respawn zombies, making sure there's always at least one
-- nearby.

-- Zombies cannot spawn in "protected areas"
-- Zombies cannot spawn too close to players
-- Zombies won't spawn if there are more than X nearby

-- Maybe:
--      Zombies cannot spawn indoors.


-- This is the starting area, zombies shouldn't spawn here.
local safe_no_spawn = {
    x1 = -14900,
    y1 = -17000,
    x2 = -9000,
    y2 = -13050
}

--=========================================================
-- Util functions
--=========================================================

function Distance2D(coords1, coords2)
    local dx = coords1.x - coords2.x
    local dy = coords1.y - coords2.y
    return math.sqrt(dx * dx + dy * dy)
end

--=========================================================

function TooCloseToPlayers(spawn_location)

    for pos = 1, Players.Count() do

        local player = Players.At(pos)
        local player_coords = Players.GetCoords(player)

        if Distance2D(player_coords, spawn_location) < 2000 then
            -- Game.Print("Too close to player")
            return true
        end
    end

    return false
end

--=========================================================

function TooManyZombiesNearby(spawn_location)

    local zombie_guids = Zombies.FindAt(spawn_location.x, spawn_location.y, 2000)

    if #zombie_guids > 5 then
        -- Game.Print(string.print("Too many zombies nearby (%d), not spawning", #zombie_guids))
        return true
    end

    return false

end

--=========================================================

function InsideProtecteAreas(spawn_location)

    if spawn_location.x > safe_no_spawn.x1 and
       spawn_location.y > safe_no_spawn.y1 and
       spawn_location.x < safe_no_spawn.x2 and
       spawn_location.y < safe_no_spawn.y2 then

        -- Game.Print("Locations inside base, won't spawn")
        return true
    end

    return false
end

--=========================================================

local debouncer_zombies = Debouncer.new(NEW_ZOMBIE_MIN_INTERVAL_SECONDS)
Game.SubscribeTo(Events.OnEverySecond, function()

    if debouncer_zombies:call() then return end
    
    local npc_count = NPCs.Count()
    local player_count = Players.Count()
    local zombie_count = Zombies.Count()

    if zombie_count >= MAX_ZOMBIES then return end

    -- local spawn_area = { x1 = 20000, y1 = 20000, x2 = -30000, y2 = -30000 -- }

    local spawn_location = {
        x = -30000 + math.random(50000),
        y = -30000 + math.random(50000),
        z = 0
    } 

    spawn_location.z = Game.GroundAt(
        spawn_location.x,
        spawn_location.y,
        spawn_location.z)
    
    if TooCloseToPlayers(spawn_location) or
        TooManyZombiesNearby(spawn_location) or
        Game.IsWater(spawn_location.x, spawn_location.y) or
        InsideProtecteAreas(spawn_location) then

        return
    end

    local aggressive = true
    local sprinter = math.random(100) < SPRINTER_PERCENT_CHANCE 
    
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