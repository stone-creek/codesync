-- Commons v1.3.1 wip

MAX_ZOMBIES                     = 0
MAX_NPCs                        = 5
SPRINTER_PERCENT_CHANCE         = 0
NEW_NPC_MIN_INTERVAL_SECONDS    = 1
NEW_ZOMBIE_MIN_INTERVAL_SECONDS = 1
ATTRIBUTES_LOOP_SECONDS         = 5

local enable_night_sprinters    = false
local enable_replenishment      = false

Game.Print("Game mode reloaded: 1.3.1 WIP")
Notifications.Global("Game mode 1.3 WIP loaded",3) --,"bram")

-- Game.SetDaysPerHour(100)
-- Game.SetHoursOffset(19)