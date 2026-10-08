-- Commons v1.3.1 wip

MAX_ZOMBIES                     = 100
MAX_NPCs                        = 10 
SPRINTER_PERCENT_CHANCE         = 1
NEW_NPC_MIN_INTERVAL_SECONDS    = 1
NEW_ZOMBIE_MIN_INTERVAL_SECONDS = 1
ATTRIBUTES_LOOP_SECONDS         = 5

local enable_night_sprinters    = false
local enable_replenishment      = false

Game.Print("Game mode reloaded: 1.3.2 WIP")
Notifications.Global("Game mode 1.3.2 WIP loaded",3) --,"bram")

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