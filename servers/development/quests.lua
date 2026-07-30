-------------------------------------------------------------------------------
-- Quests: water etc.

local NotificationsDataWater = {}

QuestMod = {}

Game.Print("---- Quest mod reloaded")

-------------------------------------------------------------------------------
-- When a player logs in, retrieves the "get the first bottle of water 
-- at the well" quest.

QuestMod.InitializePlayer = function (player)
    
    Game.Print("PLAYER ONLINE")

    local has_done_water_quest = (Players.GetMetadata(player, "quest.tutorial.water") == 'yes')
    if has_done_water_quest then
        return 
    end

    local has_any_water_on_inventory = Util.InventoryFind(player, "water-bottle")
    if has_any_water_on_inventory then
        Game.Print("Water bottle found. TODO: mark tutorial as done")
        return
    end

    local notification_guid = Notifications.Create(player, {
        message = "Get Water",
        description = "Get some water at the nearest well."
    --     hover_text = "Follow the blue arrow and talk to someone near the well, they should give you a bottle of water.",
    --     icon = "water.thirst"
    })

    NotificationsDataWater[player] = {
        guid = notification_guid,
        player = player
    }
   
    -- every few seconds, will scan the inventory. If water is present, quest is complete.
end

Game.SubscribeTo(Events.OnPlayerOnline, QuestMod.InitializePlayer)

-- Call Initialize for each player online
for pos = 1, Players.Count() do
    QuestMod.InitializePlayer(Players.At(pos))
end






-------------------------------------------------------------------------------
-- Support functions

-- WaterMod.FindNearestWellAtSpawnArea = function()

--     local all_wells = Game.AllWorldItems("water well")
--     if #all_wells == 0 then
--         return
--     end

--     local first_well = all_wells[1]
--     return first_well.coordinates

-- end