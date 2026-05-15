--=========================================================
-- Night Sprinters

local night_flag = false

if enable_night_sprinters then
    Events.SubscribeTo("every.second", function() -- no params

        -- Get time
        local hour = Game.GetDayTime()
        local is_night = (hour > 22 or hour < 2)

        Game.Print("[CLS currenthour]")
        if hour > 4 and hour < 23 then
            Game.Print("[currenthour]" .. string.format("Hours left before sunset:%.1f", 22 - hour))
        end

        -- No switch? Return.
        if is_night == night_flag then return end

        night_flag = is_night
        zombie_guids = Zombies.FindAt(-10000,-15000,100000) -- starting zone

        for pos = 1, #zombie_guids do
            local guid = zombie_guids[pos]
            Zombies.SetTraits(guid, { 
                aggressive = true,
                runner = is_night
            })
        end
    end)
end