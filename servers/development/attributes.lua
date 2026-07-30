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

        if health > 0 then
            health = health + 0.01
            energy = energy - 0.01
            hunger = hunger - 0.1
            thirst = thirst - 0.1
        else

            energy = 0
            hunger = 0
            thirst = 0
        end

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