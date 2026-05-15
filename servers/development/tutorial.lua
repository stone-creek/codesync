--=========================================================
-- Tutorial

local tutorial_steps = {
    { "Welcome to Stone Creek!", "In this quick tutorial we'll learn the basics." },
    { "Movement", "Use WASD (or IJKL if you are left-handed) to move around the map." },
    { "Movement", "Hold the main mouse button to move the camera around." },
    { "Movement", "Use the mouse wheel to zoom in/out." },
    { "Movement", "You can open/close the map pressing M." },
    { "Combat",   "Press the secondary mouse button to enter combat stance." },
    { "Combat",   "While in combat stance, you move slower but you can fight!" },
    { "Combat",   "On combat stance, press main button to attack." },
    { "Combat",   "Check your inventory with N and double-click any weapon to equip it." },
    { "Energy",   "The yellow bar on the right is your energy." },
    { "Energy",   "Sleeping on a tent when you are tired will recover your energy." },
    { "Energy",   "To sleep, find a tent, click on it, and select 'Sleep' option." },
    { "Energy",   "High energy, easier fights! Avoid fighting with low energy." },
    { "Foraging", "If you see a small shiny object on the ground, get closer to forage it." },
    { "Crafting", "You can craft things pressing the C key." },
    { "Terminal", "Pressing ENTER will activate your mini-computer. Use it to talk to others!" },
    { "Terminal", "It also has a few commands, like /help." },
    { "Terminal", "Or /tutorial, if you want to see this tutorial again." },
    { "Questions?","Check our discord at https://stonecreek.pro/discord" },
    { "Join us!", "Or the daily Twitch stream at https://twitch.tv/jsteinbach" }
}

local tutorial_metadata_id = "done-tutorial-v036"
-----------------------------------------------------------

local TerminalCallbacks = {}
TerminalCallbacks.on_close = function(player,data)
    Terminal.ScreenClose(player)
end

TerminalCallbacks.on_next = function(player,data_json)

    local index = Util.FromJson(data_json).page

    local data = {
        page = index + 1
    }

    local entry = tutorial_steps[index + 1]
    local title = entry[1]
    local message = entry[2]

    local right_button = "Finish"
    local right_callback = TerminalCallbacks.on_close

    if data.page < #tutorial_steps then
        right_button = "Next"
        right_callback = TerminalCallbacks.on_next
    else
        Players.SetMetadata(player, tutorial_metadata_id, "yes")
    end

    Terminal.ScreenSimple(player, title, message, 
        "Close", TerminalCallbacks.on_close, 
        right_button, right_callback, 
        Util.ToJson(data))
end

function ExecuteTutorial(player)
    local json = {
        page = 0
    }
    
    TerminalCallbacks.on_next(player, Util.ToJson(json))
end

-----------------------------------------------------------

-- Add the /tutorial command to display tutorial.
Terminal.Register("tutorial", "Displays a game tutorial.", ExecuteTutorial)

-- Check whenever a player gets online.
Events.SubscribeTo("player.online", function(params) 

    local done = Players.GetMetadata(params.player_guid, tutorial_metadata_id)
    if done == "yes" then return end

    ExecuteTutorial(params.player_guid)
end)