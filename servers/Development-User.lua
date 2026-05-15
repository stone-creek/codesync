-- Commons

ZOMBIES_MULTIPLIER              = 0
MAX_NPCs                        = 5
SPRINTER_PERCENT_CHANCE         = 0
NEW_NPC_MIN_INTERVAL_SECONDS    = 1
NEW_ZOMBIE_MIN_INTERVAL_SECONDS = 1

local enable_leaderboard = false
local enable_night_sprinters = false

-- Game.Print("[CLS]")
Notifications.Global("Game mode loaded",3,"bram")
-- Game.SetDaysPerHour(100)
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

--=========================================================
-- Leaderboard

Leaderboards = Game.LoadTable("leaderboards") or {}
function GetLeaderboardEntry(player_guid)

    local leaderboard = Leaderboards[player_guid]
    if leaderboard == nil then

        leaderboard = {}
        leaderboard.player_guid = player_guid
        leaderboard.player_name = Players.GetName(player_guid)
        leaderboard.arrows_shot = 0
        leaderboard.arrows_hit = 0
        leaderboard.deaths = 0
        leaderboard.kills_melee = 0
        leaderboard.kills_ranged = 0

        Leaderboards[player_guid] = leaderboard

    end

    return leaderboard

end

-----------------------------------------------------------

Events.SubscribeTo("zombie.hit", function(params) --player_guid, is_projectile, is_alive

    if not params.is_player then return end

    player_guid = params.instigator_guid
    player_name = Players.GetName(player_guid)

    if player_name == nil then return end -- could just have disconnected

    player_leaderboard_entry = GetLeaderboardEntry(player_guid)
    player_leaderboard_entry.name = player_name

    if params.is_projectile then
        player_leaderboard_entry.arrows_hit = 1 + player_leaderboard_entry.arrows_hit 

        if not params.is_alive then
            player_leaderboard_entry.kills_ranged = 1 + player_leaderboard_entry.kills_ranged
        end
    else
        if not params.is_alive then
            player_leaderboard_entry.kills_melee = 1 + player_leaderboard_entry.kills_melee
        end
    end

    Game.SaveTable("leaderboards", Leaderboards)
end)

-----------------------------------------------------------

Events.SubscribeTo("player.died", function(params) --player_guid
    player_leaderboard_entry = GetLeaderboardEntry(params.player_guid)
    player_leaderboard_entry.deaths = 1 + player_leaderboard_entry.deaths

    Game.SaveTable("leaderboards", Leaderboards)
end)

-----------------------------------------------------------

Events.SubscribeTo("player.attack", function(params) -- player_guid, is_projectile
    player_leaderboard_entry = GetLeaderboardEntry(params.player_guid)
    player_leaderboard_entry.arrows_shot = 1 + player_leaderboard_entry.arrows_shot

    Game.SaveTable("leaderboards", Leaderboards)
end)

-----------------------------------------------------------

local debouncer_leaderboard = Debouncer.new(3)
Events.SubscribeTo("every.second", function()

    if debouncer_leaderboard:call() then return end
    if enable_leaderboard ~= true then return end

    leaderboard_messages = {}

    table.insert(leaderboard_messages, "[CLS leaderboard]")
    table.insert(leaderboard_messages, "[leaderboard]Player       Kills Deaths Shots  Hits   K/A   D/K   Acc  Score")
    table.insert(leaderboard_messages, "[leaderboard]---------------------------------------------------------------")

    -- Sort the table
    local sorted = {}
    for _, v in pairs(Leaderboards) do
        table.insert(sorted, v)
    end

    table.sort(sorted, function(l,r)

        local kills_l = l.kills_ranged + l.kills_melee
        local kills_r = r.kills_ranged + r.kills_melee

        local accuracy_l = l.arrows_shot > 0 and l.arrows_hit / l.arrows_shot or 1
        local accuracy_r = r.arrows_shot > 0 and r.arrows_hit / r.arrows_shot or 1

        return (kills_l * accuracy_l) > (kills_r * accuracy_r)
    end)

    -- Format and display
    for _, v in ipairs(sorted) do


        local kills = v.kills_ranged + v.kills_melee
        local kills_per_arrow = v.arrows_shot > 0 and v.kills_ranged / v.arrows_shot or 0
        local deaths_per_kill = kills > 0 and v.deaths / kills or 0
        local accuracy = v.arrows_shot > 0 and v.arrows_hit / v.arrows_shot or 1
        local score = kills * accuracy

        local str = string.format("[leaderboard]%-14s %-5.0f %-6d %-5d %-5d %-5.1f %-5.1f %-5.1f %-5.1f",
            v.player_name:sub(1,13),
            kills,
            v.deaths,
            v.arrows_shot,
            v.arrows_hit,
            kills_per_arrow,
            deaths_per_kill,
            accuracy,
            score)

        table.insert(leaderboard_messages, str)
    end

    for _, v in ipairs(leaderboard_messages) do
        Game.Print(v)
    end

end)
--=========================================================
-- Night Sprinters

local night_flag = false

if enable_night_sprinters then
    Events.SubscribeTo("every.second", function() -- no params

        -- Get time
        local hour = Game.GetDayTime()
        local is_night = (hour > 22 or hour < 2)

        Game.Print("[CLS currenthour]")
        if hour > 4 and hour < 23 then
            Game.Print("[currenthour]" .. string.format("Hours left before sunset:%.1f", 22 - hour))
        end

        -- No switch? Return.
        if is_night == night_flag then return end

        night_flag = is_night
        zombie_guids = Zombies.FindAt(-10000,-15000,100000) -- starting zone

        for pos = 1, #zombie_guids do
            local guid = zombie_guids[pos]
            Zombies.SetTraits(guid, { 
                aggressive = true,
                runner = is_night
            })
        end
    end)
end
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

--=========================================================
-- Tutorial

local tutorial_steps = {
    { "Welcome to Stone Creek!", "In this quick tutorial we'll learn the basics." },
    { "Movement", "Use WASD (or IJKL if you are left-handed) to move around the map." },
    { "Movement", "Hold the main mouse button to move the camera around." },
    { "Movement", "Use the mouse wheel to zoom in/out." },
    { "Movement", "You can open/close the map pressing M." },
    { "Combat",   "Press the secondary mouse button to enter combat stance." },
    { "Combat",   "While in combat stance, you move slower but you can fight!" },
    { "Combat",   "On combat stance, press main button to attack." },
    { "Combat",   "Check your inventory with N and double-click any weapon to equip it." },
    { "Energy",   "The yellow bar on the right is your energy." },
    { "Energy",   "Sleeping on a tent when you are tired will recover your energy." },
    { "Energy",   "To sleep, find a tent, click on it, and select 'Sleep' option." },
    { "Energy",   "High energy, easier fights! Avoid fighting with low energy." },
    { "Foraging", "If you see a small shiny object on the ground, get closer to forage it." },
    { "Crafting", "You can craft things pressing the C key." },
    { "Terminal", "Pressing ENTER will activate your mini-computer. Use it to talk to others!" },
    { "Terminal", "It also has a few commands, like /help." },
    { "Terminal", "Or /tutorial, if you want to see this tutorial again." },
    { "Questions?","Check our discord at https://stonecreek.pro/discord" },
    { "Join us!", "Or the daily Twitch stream at https://twitch.tv/jsteinbach" }
}

local tutorial_metadata_id = "done-tutorial-v036"
-----------------------------------------------------------

local TerminalCallbacks = {}
TerminalCallbacks.on_close = function(player,data)
    Terminal.ScreenClose(player)
end

TerminalCallbacks.on_next = function(player,data_json)

    local index = Util.FromJson(data_json).page

    local data = {
        page = index + 1
    }

    local entry = tutorial_steps[index + 1]
    local title = entry[1]
    local message = entry[2]

    local right_button = "Finish"
    local right_callback = TerminalCallbacks.on_close

    if data.page < #tutorial_steps then
        right_button = "Next"
        right_callback = TerminalCallbacks.on_next
    else
        Players.SetMetadata(player, tutorial_metadata_id, "yes")
    end

    Terminal.ScreenSimple(player, title, message, 
        "Close", TerminalCallbacks.on_close, 
        right_button, right_callback, 
        Util.ToJson(data))
end

function ExecuteTutorial(player)
    local json = {
        page = 0
    }
    
    TerminalCallbacks.on_next(player, Util.ToJson(json))
end

-----------------------------------------------------------

-- Add the /tutorial command to display tutorial.
Terminal.Register("tutorial", "Displays a game tutorial.", ExecuteTutorial)

-- Check whenever a player gets online.
Events.SubscribeTo("player.online", function(params) 

    local done = Players.GetMetadata(params.player_guid, tutorial_metadata_id)
    if done == "yes" then return end

    ExecuteTutorial(params.player_guid)
end)
