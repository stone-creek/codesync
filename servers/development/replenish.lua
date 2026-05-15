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
