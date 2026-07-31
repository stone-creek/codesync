-------------------------------------------------------------------------------
-- Quests: water etc.

local NotificationsDataWater = {}

QuestMod = {}

-------------------------------------------------------------------------------
-- When a player logs in, retrieves the "get the first bottle of water 
-- at the well" quest.

QuestMod.InitializePlayer = function (player)
    
    local has_done_water_quest = (Players.GetMetadata(player, "quest.tutorial.water") == 'yes')
    if has_done_water_quest then
        return 
    end

    local has_any_water_on_inventory = Util.InventoryFind(player, "water-bottle")
    if has_any_water_on_inventory then
        Players.SetMetadata(player, "quest.tutorial.water", "yes")
        return
    end

    local notification_guid = Notifications.Create(player, {
        message = "Get Water",
        description = "Get some water at the nearest well."
    --     hover_text = "Follow the blue arrow and talk to someone near the well, they should give you a bottle of water.",
    --     icon = "water.thirst"
    })

    -- every few seconds, will scan the inventory. If water is present, quest is complete.
    NotificationsDataWater[player] = {
        player = player,
        notification_guid = notification_guid,
    }
   
end

-- Add the player initialization to the online event, and also
-- run it on current online players

Game.SubscribeTo(Events.OnPlayerOnline, QuestMod.InitializePlayer)
for pos = 1, Players.Count() do
    QuestMod.InitializePlayer(Players.At(pos))
end

local debouncer_check = Debouncer.new(2) -- every 2 seconds
Events.SubscribeTo("every.second", function()

    if debouncer_check:call() then return end

    for player_guid,data in pairs(NotificationsDataWater) do

        -- Player has water?
        local has_any_water_on_inventory = Util.InventoryFind(data.player, "water-bottle")

        if has_any_water_on_inventory then 
            Notifications.Destroy(data.notification_guid)
            NotificationsDataWater[player_guid] = nil
        end
    end

end)

-------------------------------------------------------------------------------
-- Support functions