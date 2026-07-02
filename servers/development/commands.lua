--=========================================================
-- Common commands

-----------------------------------------------------------

function tokenizeCoords(str)
    local tokens = {}
    for token in str:gmatch("[^,]+") do
        table.insert(tokens, token:match("^%s*(.-)%s*$")) -- trim whitespace
    end
    return {
        x = tonumber(tokens[1]) or 0,
        y = tonumber(tokens[2]) or 0,
        z = tonumber(tokens[3]) or 0
    }
end
-----------------------------------------------------------
Terminal.Register("gps", "Display current coordinates.", function(player)
    local coords = Players.GetCoords(player)
    Game.Print(string.format("%.1f,%.1f,%.1f", 
        coords.x,
        coords.y,
        coords.z))
end)
-----------------------------------------------------------
Terminal.Register("teleport", "Teleport the player to a location.", function(player,parameters)
    -- /teleport 8595,-10856,200
    local coords = tokenizeCoords(parameters)
    Players.Teleport(player, coords.x, coords.y, coords.z)
end)
-----------------------------------------------------------
Terminal.Register("debugdot", "Create a debug dot ingame.", function(player,parameters)
    -- /debugdot 8595,-10856,200
    local coords = tokenizeCoords(parameters)
    Debug.DrawSphere(coords.x, coords.y, coords.z, 100)
end)
-----------------------------------------------------------
Terminal.Register("players", "List all players online.", function(player)
    for pos = 1, Players.Count() do
        local player_name = Players.GetName(Players.At(pos))
        Game.Print(player_name)
    end
    Game.Print(string.format("Total online:%d", Players.Count()))
end)
-----------------------------------------------------------
Terminal.Register("home", "Teleport the player back to the starting area.", function(player) 
    player_name = Players.GetName(player)
    Game.Print("Teleporting player ".. player_name .. " to starting area")
    Players.Teleport(player, -12100, -13930, 2645)
end)
-----------------------------------------------------------