--=========================================================

local debouncer_attributes = Debouncer.new(ATTRIBUTES_LOOP_SECONDS)

Game.SubscribeTo(Events.OnEverySecond, function()

    if debouncer_attributes:call() then return end

    local Clamp = function(value)
        if value < 0 then return 0 end
        if value > 100 then return 100 end
        return value
    end

    for pos = 1, Players.Count() do

        local player = Players.At(pos)

        local health = Players.GetAttribute(player, 'health')
        local energy = Players.GetAttribute(player, 'energy')
        local hunger = Players.GetAttribute(player, 'hunger')
        local thirst = Players.GetAttribute(player, 'thirst')

        health = health + 0.01
        energy = energy - 0.01
        hunger = hunger - 0.01
        thirst = thirst - 0.01

        health = Clamp(health)
        energy = Clamp(energy)
        hunger = Clamp(hunger)
        thirst = Clamp(thirst)

        Players.SetAttribute(player, 'health', health)
        Players.SetAttribute(player, 'energy', energy)
        Players.SetAttribute(player, 'hunger', hunger)
        Players.SetAttribute(player, 'thirst', thirst)
    end
end)