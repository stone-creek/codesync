--=========================================================
-- Common commands

function ExecuteGPS(player) end
function ExecuteTeleport(player) end

function ExecuteHome(player) 
    player_name = Players.GetName(player)
    Game.Print("Teleporting player ".. player_name .. " to starting area")
    Players.Teleport(player, -12100, -13930, 2645)
end

-----------------------------------------------------------

-- Add the new commands
Terminal.Register("home", "Teleport the player back to the starting area.", ExecuteHome)