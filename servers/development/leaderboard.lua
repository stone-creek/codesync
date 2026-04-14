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