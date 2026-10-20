--=========================================================
-- Check if any zombie or NPC are stuck at the same position 
-- or in the water for too long.


local last_coords = {}

function IsStuck(guid, x, y, z)

    local now = Game.GetTime()

    local entry = last_coords[guid]
    if entry == nil then
        entry = {
            x = x,
            y = y,
            z = z,
            updated = now
        }
        last_coords[guid] = entry
    end

    -- Detect movement
    if x ~= entry.x or y ~= entry.y or z ~= entry.z then
            entry.x = x
            entry.y = y
            entry.z = z
            entry.updated = now
            last_coords[guid] = entry
    end

    -- 10 minutes
    return (now - entry.updated > 600);
end

local debouncer_despawn = Debouncer.new(10)
Game.SubscribeTo(Events.OnEverySecond, function()

    -- if debouncer_despawn:call() then return end
    
    for pos = NPCs.Count(), 1, -1 do
        local npc = NPCs.At(pos)
        local coords = NPCs.GetCoords(npc)

        if Game.IsWater(coords.x, coords.y) then
            Game.Log(string.format("Found NPC on water at %.0f,%.0f,%.0f", coords.x, coords.y, coords.z))
            last_coords[npc] = nil
            NPCs.Destroy(npc)
            return
        end

        if IsStuck(npc,coords.x,coords.y,coords.z) then
            Game.Print(string.format("Found NPC stuck at %.0f,%.0f,%.0f", coords.x, coords.y, coords.z))
            last_coords[npc] = nil
            NPCs.Destroy(npc)
            return
        end

    end

end)
