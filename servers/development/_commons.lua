-- Commons v1.3.1 wip

MAX_ZOMBIES                     = 100
MAX_NPCs                        = 10 
SPRINTER_PERCENT_CHANCE         = 0
NEW_NPC_MIN_INTERVAL_SECONDS    = 1
NEW_ZOMBIE_MIN_INTERVAL_SECONDS = 1
ATTRIBUTES_LOOP_SECONDS         = 5

local enable_night_sprinters    = false
local enable_replenishment      = false

Game.Print("Game mode reloaded: 1.3.3 WIP")
Notifications.Global("Game mode 1.3.3 WIP loaded",3) --,"bram")

-- Game.SetDaysPerHour(100)
-- Game.SetHoursOffset(19)

-- -- Some code to test 
-- Game.SubscribeTo(Events.OnEverySecond, function()
--     for pos = 1, Players.Count() do
--         local player = Players.At(pos)
--         local coords = Players.GetCoords(player)

--         if Game.IsWater(coords.x,coords.y) then
--             Game.Print("water")
--         else
--             Game.Print("not water")
--         end
--     end
-- end)


--=========================================================
-- Test: will spawn zombies every 5 seconds a few meters
-- away from the player, but will despawn them if too close
-- every second.

-- local debouncer_pop = Debouncer.new(5)
-- Game.SubscribeTo(Events.OnEverySecond, function()
--     if debouncer_pop:call() then return end
--     for pos_player = 1, Players.Count() do 
--         local player = Players.At(pos_player)
--         local coords = Players.GetCoords(player)
--         local x,y,z = Game.InFrontOf(player,1500,0)
--         Debug.DrawSphere(x, y, z, 50)
--         local list_zombies_near = Zombies.FindAt(x,y, 300)
--         -- Ok to spawn, no other Zombie nearby?
--         if #list_zombies_near == 0 then
--             Zombies.Create(x, y, z, math.random(360), true, false)
--         end
--     end
-- end)

-- Game.SubscribeTo(Events.OnEverySecond, function()
--     for pos_player = 1, Players.Count() do 
--         local player = Players.At(pos_player)
--         local coords = Players.GetCoords(player)
--         local list_zombies_near = Zombies.FindAt(coords.x,coords.y, 300)
--         for pos = 1, #list_zombies_near do
--             local zombie = list_zombies_near[pos]
--             Game.Log(string.format("Destroying Zombie %s", zombie))
--             Zombies.Destroy(zombie)
--         end
--     end
-- end)